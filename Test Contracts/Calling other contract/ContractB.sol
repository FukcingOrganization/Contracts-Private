// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ContB{
    address public otherContract;
    mapping (address => uint256) public swordBalance;

    constructor (address _otherContractAddress) {
        otherContract = _otherContractAddress;
    }

    function buySword () public returns (bool) {
        bytes memory payload = abi.encodeWithSignature("burnFromAddress(address,uint256)", msg.sender, 40);
        (bool success, bytes memory returnData) = otherContract.call(payload);
        require(success, "Failed!");
        swordBalance[msg.sender] += 1;
        return true;
    }

    // How to get return data
    function return50 () public returns (uint256) {        
        bytes memory payload = abi.encodeWithSignature("return50()");
        (bool success, bytes memory returnData) = otherContract.call(payload);
        require(success, "Failed!");
        
        (uint256 fifty) = abi.decode(returnData, (uint256));
        return fifty;
    }
}