//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * ERC20 token -> transfer, allowance, approve, transferFrom
 * read functions -> getBalance, totalSupply, name, symbol, decimal
*/

import "./node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract ERC20Token is ERC20{
    
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){
        // minting 100 _name tokens, native token is eth
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}

// txn hash -> 0xb7a3b9cc9ad0a141a22d4a9baf83b164f819d6140ecdef0b27dba4194d6593c9
// contract address -> 0x630c760cad9ad891ed99fbb83b31eb3df231c145
// deployed on amoy polygon testnet chain