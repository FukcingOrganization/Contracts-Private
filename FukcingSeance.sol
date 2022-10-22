// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
  * -> To-do: 
  * -> View funcion for the levels and elections. Get winner or winners from level(s)
  */

/*
 * @author Bora
 */

/**
  * Info:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  * -> Every player can claim just 1 reward for each level no matter how many times he/she played. 
  * ---> We put the players in a merkle root and they claim their reward. 
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
    uint256 totalNumberOfPlayer;
    bytes32 merkleRoot;
    mapping(address => bool) isPlayerClaimed;
    mapping(address => bool) isBackerClaimed;
  }

  struct Seance{
    uint256 endingTime;
    Level[13] levels;
    uint256 seanceRewards;
  }

  enum Status{
    NotStarted, // Index: 0
    OnGoing,    // Index: 1
    Approved,   // Index: 2
    Denied      // Index: 3
  }

  struct Proposal {
    Status status;
    uint256 updateCode; // Update code helps to differentiate different variables with same data type. Starts from 1.
    bool isExecuted;    // If executed, the data and proposal no longer can be used.
    
    uint256 index;      // The index of target array. See arrays below.
    uint256 newUint;
    address newAddress;
    bytes32 newBytes32;
    bool newBool;
  }

  /**
   * proposalTypes's Indexes with corresponding meaning
   *  
   * Index 0: Less important proposals
   * Index 1: Moderately important proposals
   * Index 2: Highly important proposals
   * Index 3: MAX SUPPLY CHANGE PROPOSAL
  */
  uint256[4] public proposalTypes;

  /**
   * contracts' Indexes with corresponding meaning
   *  
   * Index 0: Boss Contract             
   * Index 1: Clan Contract              
   * Index 2: ClanLicence Contract        
   * Index 3: Community Contract         
   * Index 4: DAO Contract               
   * Index 5: Executor Contract            
   * Index 6: Items Contract            
   * Index 7: Lord Contract               
   * Index 8: Rent Contract               
   * Index 9: Seance Contract             
   * Index 10: Staking Contract           
   * Index 11: Token Contract          
   * Index 12: Developer Contract/address  
   */
  address[13] public contracts; 

  mapping(uint256 => Proposal) public proposals;// Proposal ID => Proposal
  mapping(uint256 => Seance) public seances;
  
  Counters.Counter public seanceCounter;

  uint256[13] levelRewardWeights;
  uint256 totalRewardWeight;

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
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This fukcing boss doesn't even exist!");
    // Get the funds!
    require(IERC20(contracts[11]).transferFrom(_msgSender(), address(this), _fundAmount), "Couldn't receive funds!");

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
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This fukcing boss doesn't even exist!");
    
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

    require(IERC20(contracts[11]).transfer(_msgSender(), _withdrawAmount), "Something went wrong while you're trying to withdraw!");

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
      (bool txSuccess0, ) = address(contracts[11]).call(abi.encodeWithSignature("burn(uint256)", burnAmount));
      require(txSuccess0, "Burn tx has failed!");  

      // Record the fukc
      (bool txSuccess1, ) = address(contracts[0]).call(abi.encodeWithSignature("bossFukced(uint256)", election.winnerID));
      require(txSuccess1, "Fukc Record tx has failed!");
    }

    // Now we have burnt the losers' funds and save the winner's balance. Time to start next Seance!
    uint256 previousTime = _currentSeance.endingTime;
    seanceCounter.increment();
    seances[seanceCounter.current()].endingTime = previousTime + 7 days;
    getBackerRewards(seances[seanceCounter.current()]);
  }

  function claimPlayerReward(bytes32[] calldata _merkleProof, uint256 _seanceNumber, uint256 _levelNumber) public {
    require(block.timestamp > seances[_seanceNumber].endingTime, "Wait for the end of the seance!");
    require(seances[_seanceNumber].endingTime != 0, "Invalied seance number!"); // If there is no end time
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");

    Level storage level = seances[_seanceNumber].levels[_levelNumber];
    address sender = _msgSender();

    // Check if the player is in the list or not
    bytes32 leaf = keccak256(abi.encodePacked(sender));
    require(MerkleProof.verify(_merkleProof, level.merkleRoot, leaf), "Bro, you are not even in the player list!");

    // Check if the player is already claimed
    require(level.isPlayerClaimed[sender] == false, "Dude! You have already claimed your reward! Why too aggressive?");
    level.isPlayerClaimed[sender] = true;
    
    // Give the reward
    uint256 fukcingReward = level.playerReward / level.totalNumberOfPlayer;
    require(IERC20(contracts[11]).transfer(sender, fukcingReward), "Something went wrong while you're trying to get your fukcing reward!");
  }
  
  function claimBackerReward(uint256 _seanceNumber, uint256 _levelNumber) public {
    require(block.timestamp > seances[_seanceNumber].endingTime, "Wait for the end of the seance!");
    require(seances[_seanceNumber].endingTime != 0, "Invalied seance number!");
    require(_levelNumber >= 0 && _levelNumber < 13, "Invalid level number!");

    Level storage level = seances[_seanceNumber].levels[_levelNumber];
    Election storage election = level.election;
    address sender = _msgSender();

    require(level.isBackerClaimed[sender] == false, "Wow wow wow! You already claimed your shit bro. Back off!");
    level.isBackerClaimed[sender] == true;

    // rewardAmount = backerReward * backerfund / total fund
    uint256 fukcingReward = level.backerReward * 
      election.backerFunds[election.winnerID][sender] / election.candidateFunds[election.winnerID];
    require(IERC20(contracts[11]).transfer(sender, fukcingReward), "Something went wrong while you're trying to get your fukcing reward!");
  }

  function returnMerkleRoot(uint256 _seanceNumber, uint256 _levelNumber) public view returns (bytes32) {
    return seances[_seanceNumber].levels[_levelNumber].merkleRoot;
  }

  function getBackerRewards(Seance storage _seance) internal {
    // Get the backer rewards from fukcing token
    (bool txSuccess, bytes memory returnData) = contracts[11].call(abi.encodeWithSignature("backerMint()"));
    require(txSuccess, "Transaction has failed to get backer rewards from Fukcing Token contract!");
    (_seance.seanceRewards) = abi.decode(returnData, (uint256));

    // Distribute it according to level weights
    for (uint256 i = 0; i < 13; i++) {
      _seance.levels[i].backerReward = _seance.seanceRewards * levelRewardWeights[i] / totalRewardWeight;
    }
  }

  function updateLevelRewardRates(uint256 _level, uint256 _newWeight) public {
    require(_msgSender() == contracts[5], "Only the Fukcing Executors can update the level reward rates!!");
    require(_level >= 0 && _level < 13, "Dude! Check the level number! It can be 0 to 12!");

    // Update total weight
    if (levelRewardWeights[_level] > _newWeight)
      totalRewardWeight -= levelRewardWeights[_level] - _newWeight;
    else
      totalRewardWeight += _newWeight - levelRewardWeights[_level];
    
    // Update level weight
    levelRewardWeights[_level] = _newWeight;
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Seance contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
      Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4]) - proposal type : 2 - Highly Important
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID to create proposal in here
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the proposal
    proposals[propID].updateCode = 1;
    proposals[propID].index = _contractIndex;
    proposals[propID].newAddress = _newAddress;
  }

  function executeContractAddressUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 1 || proposal.isExecuted == false, "Wrong proposal ID");
    
    // Get the result from DAO
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
    );
    require(txSuccess, "Transaction failed to retrieve DAO result!");
    (uint256 statusNum) = abi.decode(returnData, (uint256));

    // Save it here
    proposal.status = Status(statusNum);

    // Wait for the current one to finalize
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if approved, apply the update the state
    if (proposal.status == Status.Approved)
      contracts[proposal.index] = proposal.newAddress;

    proposal.isExecuted = true;
  }

  function proposeProposalTypesUpdate(uint256 _proposalIndex, uint256 _newType) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Seance contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
      Strings.toHexString(_newType), " from ", Strings.toHexString(proposalTypes[_proposalIndex]), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4]) - proposal type : 2 - Highly Important
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
        abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Get data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].index = _proposalIndex;
    proposals[propID].newUint = _newType;
  }

  function executeProposalTypesUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 2 || proposal.isExecuted == false, "Wrong proposal ID");

    // If there is already a proposal, Get its result from DAO
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
    );
    require(txSuccess, "Transaction failed to retrieve DAO result!");
    (uint256 statusNum) = abi.decode(returnData, (uint256));

    // Save it here
    proposal.status = Status(statusNum);

    // Wait for the current one to finalize
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the current one is approved, apply the update the state
    if (proposal.status == Status.Approved)
      proposalTypes[proposal.index] = proposal.newUint;

    proposal.isExecuted = true;
  }
}