// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";


contract propCreator {
    using Counters for Counters.Counter;

    enum propStatus {NotStarted, OnGoing, Finalized}

    struct Proposal {
        uint256 id;
        propStatus status;
    }

    Counters.Counter propCounter;

    mapping (uint256 => Proposal) props;
    address public daoContract;

    mapping (address => uint256) public swordBalance;

    function defineCreator (address _creatorAddress) public {
        daoContract = _creatorAddress;
    }

    function newProp (string memory _description, uint256 _lenght) public {
        bytes memory payload = abi.encodeWithSignature("newProp(string,uint256)", _description, _lenght);
        (bool ts, bytes memory returnData) = daoContract.call(payload);
        require(ts, "Transaction failed!");

        // Check return data to be sure a new proposal is being created
        (bool isNewPropCreated) = abi.decode(returnData, (bool));
        require(isNewPropCreated, "New proposal creation failed!");
    }

    function propResult (uint256 _propID) public returns (bool) {
        bytes memory payload = abi.encodeWithSignature("propResult(uint256)", _propID);
        (bool ts, bytes memory returnData) = daoContract.call(payload);
        require(ts, "Transaction failed!");

        (bool result) = abi.decode(returnData, (bool));
        return result;
    }
}

/*
    60 - 1m
    180 - 3m
    360 - 5m
*/