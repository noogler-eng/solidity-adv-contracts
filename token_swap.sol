//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract ERC20Token is ERC20{
    
    IERC20 public tokenAContract;
    IERC20 public tokenBContract;

    constructor(address _token_A, address _token_B){
        tokenAContract = IERC20(_token_A);
        tokenBContract = IERC20(_token_B);
    }

    function swap(uint256 _amountTokenAToTransfer, uint256 _amountTokenBToTransfer, address _tokenBOwner){
        require(tokenAContract.balanceOf(msg.sender) > _amountTokenAToTransfer, 'insufficent balance');
        require(tokenBContract.balanceOf(_tokenBOwner) > _amountTokenBToTransfer, 'insufficent balance');
        
        // when they both aggred B allowed for allowance and maention them
        require(tokenBContract.allowance(_tokenBOwner, msg.sender) >= _amountTokenBToTransfer, 'insufficent allownace of B on A');
        
        bool isDone1 = IERC20.transferFrom(msg.sender, _tokenBOwner, _amountTokenAToTransfer);
        bool isDone2 = IERC20.transferFrom(_tokenBOwner, msg.sender, _amountTokenBToTransfer);
        require( isDone1 && isDone2, 'txn failed');
    }

    // allowance will given to owner a or msg.sender to send the tokens of B
}

