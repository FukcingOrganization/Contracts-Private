// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ContA {
    mapping (address => uint256) public balances;
    address myAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

    constructor (){
        balances[myAddress] = 100;
    }

    function burnFromAddress (address _address, uint256 _amount) public returns (bool) {
        require(balances[_address] >= _amount, "Not enough balance to burn");
        balances[_address] -= _amount;
        return true;
    }
}