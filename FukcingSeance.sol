// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
  * Handles boss selection and reward distribution
  * -> Seance[level[election]]]
  * -> Update: DAO, Executer, FUKC add, UpdatePropType, 
  */

/*
 * @author Bora
 */

contract FukcingSeance {
  using Counters for Counters.Counter;

  enum SeanceStatus{
    NotStarted, // Index: 0
    OnGoing,    // Index: 1
    Ended       // Index: 2
  } 

  struct Election{
    uint256[] candidateIDs;
    mapping(uint256 => bool) isCandidate;       // ID => isCandidate?
    mapping(uint256 => uint256) candidateFunds; // ID => funds
    uint256 winnerID;
  }

  struct Level{
    Election election;
    uint256 levelRewards;
    bytes32[] merkleRoots;
    uint256[] claims;
  }

  struct Seance{
    SeanceStatus status;
    uint256 startTime;
    Level[13] levels;
    uint256 seanceRewards;
  }

  mapping(uint256 => Seance) seances;
  
  Counters.Counter private seanceCounter;

  address fukcingExecutors;
  IERC20 fukcingDAO;
  IERC20 fukcingToken;
  IERC721 fukcingBoss;

  constructor() {
    initializeFirstSeance();
  }

  function BossFunding(uint256 _levelNumber, uint256 _bossID, uint256 _fundAmount) public returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");
    require(seances[seanceCounter.current()].startTime + 6 days > block.timestamp, 
      "The funding round is closed for this seance. Maybe next time sweetie!"
    );
    // Check if the boss even exist
    require(fukcingBoss.ownerOf(_bossID) != address(0), "This fukcing boss doesn't even exist!");
    // Get the funds!
    require(fukcingToken.transferFrom(msg.sender, address(this), _fundAmount), "Couldn't receive funds!");

    Election storage election = seances[seanceCounter.current()].levels[_levelNumber].election;
    // If the boss already a candidate
    if (election.isCandidate[_bossID]){
      election.candidateFunds[_bossID] += _fundAmount;
    }
    else {  // If it is not registered, than register.
      election.isCandidate[_bossID] = true;
      election.candidateIDs.push(_bossID);
      election.candidateFunds[_bossID] += _fundAmount;
    }

    return true;    
  }

  function updateSeanceStatus() internal {
    // If time is up, start the next seance
    if (block.timestamp > seances[seanceCounter.current()].startTime + 7 days){
      startNextSeance();
    }
  }

  function startNextSeance() internal {
    seanceCounter.increment();

    
  }

  function initializeFirstSeance() internal {
    Seance storage seance = seances[seanceCounter.current()];
    seance.status = SeanceStatus.OnGoing;
    seance.startTime = block.timestamp;
  }
}