// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
  * -> To-do: 
  **** -> Get Backer rewards when starting new seance (waits for token contract to complete)
  **** -> Distribute rewards exponantially between levels from 1 to 13.
  * -> Update: DAO, Executer, FUKCCont, PlayerCont add, UpdatePropType, 
  */

/*
 * @author Bora
 */

/**
  * Info:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */

contract FukcingSeance is Context, ReentrancyGuard {
  using Counters for Counters.Counter;

  struct Election{
    uint256[] candidateIDs;
    mapping(uint256 => bool) isCandidate;       // candidate ID => isCandidate?
    mapping(uint256 => uint256) candidateFunds; // candidate ID => total amount of fund
    mapping(uint256 => mapping(address => uint256)) backerFunds; // ID => backer => fund Amount
    uint256 winnerID;
  }

  struct Level{
    Election election;
    uint256 playerReward;
    uint256 backerReward;
    bytes32[] merkleRoots;
    uint256[] rewards;
    mapping(address => bool) isPlayerClaimed;
    mapping(address => bool) isBackerClaimed;
  }

  struct Seance{
    uint256 endingTime;
    Level[13] levels;
    uint256 seanceRewards;
  }

  mapping(uint256 => Seance) public seances;
  
  Counters.Counter public seanceCounter;

  address public fukcingExecutors;
  IERC20 public fukcingDAO;
  IERC20 public fukcingToken;
  IERC721 public fukcingBoss;

  uint256[13] levelRewardRates;

  constructor(uint256 _endOfTheFirstSeance) {
    seances[seanceCounter.current()].endingTime = _endOfTheFirstSeance; // TEST -> Change it with unix value of Monday 00.00
    getBackerRewards(seances[seanceCounter.current()]);     
  }

  function bossFunding(uint256 _levelNumber, uint256 _bossID, uint256 _fundAmount) public nonReentrant() returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");

    Seance storage seance = seances[seanceCounter.current()];

    // If current seance has ended, start the new one before funding
    if (block.timestamp > seance.endingTime){
      startNextSeance(seance);
    }

    // Close funding in the last day of the seance
    require(seance.endingTime - 1 minutes  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this seance. Maybe next time sweetie!"
    );
    // Check if the boss if it exists - If it has an owner, than it exists
    require(fukcingBoss.ownerOf(_bossID) != address(0), "This fukcing boss doesn't even exist!");
    // Get the funds!
    require(fukcingToken.transferFrom(_msgSender(), address(this), _fundAmount), "Couldn't receive funds!");

    Election storage election = seance.levels[_levelNumber].election;
    // If the boss is not a candidate yet, make it a candidate for this level
    if (election.isCandidate[_bossID] == false){
      election.isCandidate[_bossID] = true;
      election.candidateIDs.push(_bossID);
    }
    // Add funds
    election.candidateFunds[_bossID] += _fundAmount;
    election.backerFunds[_bossID][_msgSender()] += _fundAmount;

    return true;    
  }

  function withdrawBossFunds(uint256 _levelNumber, uint256 _bossID, uint256 _withdrawAmount) public nonReentrant() returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");
    require(fukcingBoss.ownerOf(_bossID) != address(0), "This fukcing boss doesn't even exist!");
    
    Seance storage seance = seances[seanceCounter.current()];

    require(seance.endingTime - 1 minutes  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this seance. Too late sweetie!"
    );

    Election storage election = seance.levels[_levelNumber].election;
    require(election.isCandidate[_bossID] == true, "This fukcing boss is not even a candidate!");
    require(election.backerFunds[_bossID][_msgSender()] >= _withdrawAmount, "You can't withdraw more than you deposited!");

    // If everything goes well, subtract funds
    election.candidateFunds[_bossID] -= _withdrawAmount;
    election.backerFunds[_bossID][_msgSender()] -= _withdrawAmount;

    require(fukcingToken.transfer(_msgSender(), _withdrawAmount), "Something went wrong while you're trying to withdraw!");

    return true;
  }

  function startNextSeance(Seance storage _currentSeance) internal {
    // Iterate through all 13 level
    for (uint i = 0; i < 13; i++){
      Election storage election = _currentSeance.levels[i].election;

      // Find Winner Boss
      election.winnerID = election.candidateIDs[0];
      for (uint j = 1; j <= election.candidateIDs.length; j++){  // all candidates
        if (election.candidateFunds[election.candidateIDs[j]] > election.candidateFunds[election.candidateIDs[election.winnerID]])
          election.winnerID = election.candidateIDs[j];
      }

      uint256 burnAmount;
      // Keep the winner's fund for player reward and burn the losers' funds!
      for (uint k = 0; k < election.candidateIDs.length; k++){  // all candidates
        if (election.candidateIDs[k] == election.winnerID){
          _currentSeance.levels[i].playerReward = election.candidateFunds[election.candidateIDs[k]];
        }
        else{          
          burnAmount += election.candidateFunds[election.candidateIDs[k]];
        } 
      }
      // Burn them all!
      (bool txSuccess0, ) = address(fukcingToken).call(abi.encodeWithSignature("burn(uint256)", burnAmount));
      require(txSuccess0, "Burn tx has failed!");  

      // Record the fukc
      (bool txSuccess1, ) = address(fukcingBoss).call(abi.encodeWithSignature("bossFukced(uint256)", election.winnerID));
      require(txSuccess1, "Fukc Record tx has failed!");
    }

    // Now we have burnt the losers' funds and save the winner's balance. Time to start next Seance!
    uint256 previousTime = _currentSeance.endingTime;
    seanceCounter.increment();
    seances[seanceCounter.current()].endingTime = previousTime + 7 days;
    getBackerRewards(seances[seanceCounter.current()]);
  }

  function claimPlayerReward(bytes32[] calldata _merkleProof, uint256 _seanceNumber, uint256 _levelNumber) public returns (bool) {
    require(block.timestamp > seances[_seanceNumber].endingTime, "Wait for the end of the seance!");
    require(seances[_seanceNumber].endingTime != 0, "Invalied seance number!");
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");

    Level storage level = seances[_seanceNumber].levels[_levelNumber];
    
    uint256 fukcingReward = merkleCheck(level, _merkleProof);
    require(fukcingReward > 0, "You don't have any reward, sorry dude!");

    require(fukcingToken.transfer(_msgSender(), fukcingReward), "Something went wrong while you're trying to get your fukcing reward!");

    return true;
  }
  
  function claimBackerReward(uint256 _seanceNumber, uint256 _levelNumber) public returns (bool) {
    require(block.timestamp > seances[_seanceNumber].endingTime, "Wait for the end of the seance!");
    require(seances[_seanceNumber].endingTime != 0, "Invalied seance number!");
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");

    Level storage level = seances[_seanceNumber].levels[_levelNumber];
    Election storage election = level.election;

    require(level.isBackerClaimed[_msgSender()] == false, "Wow wow wow! You already claimed your shit bro. Back off!");
    level.isBackerClaimed[_msgSender()] == true;

    // rewardAmount = backerReward * backerfund / total fund
    uint256 fukcingReward = level.backerReward * 
      election.backerFunds[election.winnerID][_msgSender()] * election.candidateFunds[election.winnerID];
    require(fukcingToken.transfer(_msgSender(), fukcingReward), "Something went wrong while you're trying to get your fukcing reward!");

    return true;
  }

  function merkleCheck(Level storage _level, bytes32[] calldata _merkleProof) internal returns (uint256) {
    require(_level.isPlayerClaimed[_msgSender()] == false, "Dude! You have already claimed your reward! Why too aggressive?");

    uint256 reward;
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
    for (uint256 i = 0; i < _level.merkleRoots.length; i++){
      // If the proof valid for this index, get the reward of this index
      if (MerkleProof.verify(_merkleProof, _level.merkleRoots[i], leaf)){
        _level.isPlayerClaimed[_msgSender()] = true;
        reward = _level.rewards[i];
        break;
      }
    }
    return reward;
  }

  function returnMerkleRoots(uint256 _seanceNumber, uint256 _levelNumber) public view returns (bytes32[] memory) {
    return seances[_seanceNumber].levels[_levelNumber].merkleRoots;
  }

  function returnAllowances(uint256 _seanceNumber, uint256 _levelNumber) public view returns (uint256[] memory) {
    return seances[_seanceNumber].levels[_levelNumber].rewards;
  }

  function getBackerRewards(Seance storage _seance) internal {
    // Get the backer rewards from fukcing token
    //mint
    // Distribute it according to levelRewardRates
  }
}