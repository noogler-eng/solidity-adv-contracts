//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultSignWallet{

    address[] owners;
    uint256 public noOfConfirmationRequired;
    mapping( address => bool ) public isOwner;

    struct Txn {
        address to;
        uint256 value;
        bytes data; 
        bool executed;
        uint256 noOfApprovals;
    }

    mapping( uint256 => mapping( address => bool) ) idToOwnerIsApproved;

    Txn[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], 'not an owner of wallet');
        _;
    }

    event Deposit(address _from, uint256 _amount, uint256 _balance);

    constructor(address[] memory _owners, uint256 _noOfConfirmationRequired) {
        require(_owners.length > 0, 'owners required');
        require(_noOfConfirmationRequired > 0 && _noOfConfirmationRequired <= _owners.length, 'invalid no of confirmation required!');
        
        for(uint256 i; i<_owners.length; i++){
            require(_owners[i] != address(0));
            require(isOwner[_owners[i]] == false, 'owner is already added!');
            owners.push(_owners[i]); 
            isOwner[_owners[i]] = true;
        }

        noOfConfirmationRequired = _noOfConfirmationRequired;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance; 
    }

    function submitTxn(address _to, uint256 _value, bytes memory _data) public onlyOwner{
        uint256 txnId = transactions.length;
        transactions.push(Txn({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            noOfApprovals: 1
        }));
        idToOwnerIsApproved[txnId][msg.sender] = true;
    }

    function confirmTxm(uint256 _id) public onlyOwner {
        Txn storage transact = transactions[_id];
        transact.noOfApprovals = transact.noOfApprovals + 1;
        idToOwnerIsApproved[_id][msg.sender] = true;
        
        if(transact.noOfApprovals >= noOfConfirmationRequired){
            executeTxn(_id);
        }
    }

    function executeTxn(uint256 _id) public {
        Txn storage transact = transactions[_id];
        require(transact.noOfApprovals >= noOfConfirmationRequired, 'no sufficent approvals');
        require(address(this).balance > transact.value, 'insufficient balance');
        (bool success, ) = payable(transact.to).call{value: transact.value}("");
        require(success, 'transaction failed');
        transact.executed = true;
    }

    function revokeConfirmation(uint256 _id) public {
        Txn storage transact = transactions[_id];
        transact.noOfApprovals = transact.noOfApprovals - 1;
        idToOwnerIsApproved[_id][msg.sender] = false;
    }

    // A simple way to receive Ether with no data
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Called when a contract is sent Ether with data or when no other function matches the call.
    fallback() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

}