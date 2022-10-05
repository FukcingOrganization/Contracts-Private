// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";

contract DAOtest {
    using Counters for Counters.Counter;

    enum propStatus {NotStarted, OnGoing, Approved, Denied}

    struct Proposal {
        uint256 id;
        propStatus status;
        string description;
        uint256 startTime;
        uint256 length;
        uint256 yayCount;
        uint256 nayCount;
    }

    Counters.Counter propCounter;
    mapping (uint256 => Proposal) props;

    uint256 public testVar;

    function returnEnum () pure public returns (uint256) {
        return uint256(propStatus.OnGoing);                                          // returns directly normal propStatus
    }
    function checkEnum (uint256 _propID) view public returns (uint256) {   
        return uint256(props[_propID].status);                                       // returns directly propStatus from the written prop
    }

    function writeProp (uint256 _number) public {
        Proposal storage newProp = props[propCounter.current()];

        newProp.id = propCounter.current();
        newProp.status = propStatus(_number);                               // uint256 to propStatus

        propCounter.increment();
    }
    function newProp (string memory _description, uint256 _length) public returns (bool) {        
        Proposal storage newProp = props[propCounter.current()];

        testVar = _length;

        newProp.id = propCounter.current();
        newProp.status = propStatus.OnGoing;                               // uint256 to propStatus
        newProp.description = _description;
        newProp.startTime = block.timestamp;
        newProp.length = _length;

        propCounter.increment();

        return true;
    }
    function voteProp (uint256 _propID, bool _isVotingFor) public {
        if (_isVotingFor){
            props[_propID].yayCount++;
        }
        else {
            props[_propID].nayCount++;
        }
    }
    function propInfo (uint256 _propID) view public returns (propStatus, uint256, string memory, bool) {
        return (props[_propID].status , props[_propID].length, props[_propID].description, props[_propID].yayCount > props[_propID].nayCount);
    }
    function propResult (uint256 _propID) view public returns (bool) {       
        Proposal storage prop = props[_propID];
        require(prop.startTime + prop.length < block.timestamp, "The prop is stil ongoing");

        return prop.yayCount > prop.nayCount;
    }
}