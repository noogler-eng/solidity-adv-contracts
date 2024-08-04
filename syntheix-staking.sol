//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking{

    // The rate at which rewards are distributed
    uint256 public rewardRate;
    // The accumulated reward per token
    uint256 public rewardPerTokenStored;
    // The total supply of staked tokens
    uint256 public stakeTokenTotalSupply;
    // Timestamp of the last reward calculation
    uint256 public lastRewardUpdateTime;
    

    mapping( address => uint256 ) balances;
    // Tracks rewards per token paid to each user
    mapping( address => uint256 ) public userRewardPerTokenPaid;
    // Stores pending rewards for each user
    mapping( address => uint256 ) public rewards;

    // ERC20 token contracts for staking and rewards
    IERC20 public stakingTokenContract;
    IERC20 public rewardTokenContract;

    constructor(uint256 _rewardPerSecond, address _stakingToken, address _rewardToken){
        rewardRate = _rewardPerSecond;
        stakingTokenContract = IERC20(_stakingToken);
        rewardTokenContract = IERC20(_rewardToken);
    }

    modifier _updateRewards(address _user) {
        rewardPerTokenStored = rewardPerToken();
        lastRewardUpdateTime = block.timestamp;
        rewards[_user] = earned(_user);
        userRewardPerTokenPaid[_user] = rewardPerTokenStored;
        _;
    }

    // transfer tokens to the user using payable(msg.sender).call{value: _amount}(""); 
    // which is used for transferring Ether, not ERC20 tokens
    function stake(uint256 _amount) external payable _updateRewards(msg.sender){
        require(_amount > 0, 'amount must be greater then 0');
        require(stakingTokenContract.balanceOf(msg.sender) >= _amount, 'insufficent funds');

        bool isDone = stakingTokenContract.transferFrom(msg.sender, address(this), _amount);
        require(isDone, 'staking failed');

        stakeTokenTotalSupply += _amount;
        balances[msg.sender] += _amount;
    }

    function unstake(uint256 _amount) external _updateRewards(msg.sender){
        require(balances[msg.sender] >= _amount, 'insufficent staking according to your unstake ask!');

        // payable with ERC20 Transfers: The payable keyword is not necessary when transferring ERC20 tokens. 
        // It is used for transferring Ether, not ERC20 token
        bool isDone = stakingTokenContract.transfer(msg.sender, _amount);
        require(isDone, 'unstaking failed');
        balances[msg.sender] -= _amount;
        stakeTokenTotalSupply -= _amount;
    }

    function getReward() external {
        require(rewards[msg.sender] > 0, 'you dont have any rewards token');

        bool isDone = rewardTokenContract.transfer(msg.sender, rewards[msg.sender]);
        require(isDone, 'rewards txn failed');
        rewards[msg.sender] = 0;
    }   

    function rewardPerToken() private view returns(uint256) {
        if ( stakeTokenTotalSupply == 0 ){
            return 0;
        }

        return rewardPerTokenStored + 
            ((rewardRate * (block.timestamp - lastRewardUpdateTime)* 1e18) / stakeTokenTotalSupply);
    }
    
    function earned(address _account) private view returns(uint256) {
        return (balances[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account]) / 1e18) + rewards[_account];
    }

}