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


/**
  * @notice
  * -> A round is a week and in every round, players selects 1 boss for each level by funding them.
  * The funds of the winner boss goes to the players of that level in the following round.
  * The funds of the loser bosses burns!
  *
  * -> Every player can claim just 1 reward for each level no matter how many times he/she played. 
  *
  * -> Executors sets merkle roots for players to claim their rewards.
  *
  * -> Backers of winner bosses can claim their reward without executors. 
  * Backer rewards accounts 5% of STICK total supply.
  *
  * -> Higher levels have higher backer reward which will result with higher funding and 
  * higher reward for players.
  */

/**
 * @author Bora
 */
contract StickRound is Context, ReentrancyGuard {
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
  }

  struct Round{
    uint256 endingTime;
    Level[10] levels;
    uint256 roundRewards;
    mapping(address => bool) isPlayerClaimed;
    mapping(address => bool) isBackerClaimed;
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

  uint256 public proposalTypeIndex;

  /**
   * contracts' Indexes with corresponding meaning
   *  
   * Index 0: Boss Contract             
   * Index 1: Clan Contract              
   * Index 2: ClanLicense Contract        
   * Index 3: Community Contract         
   * Index 4: DAO Contract               
   * Index 5: Executor Contract            
   * Index 6: Items Contract            
   * Index 7: Lord Contract               
   * Index 8: Rent Contract               
   * Index 9: Round Contract             
   * Index 10: Staking Contract           
   * Index 11: Token Contract          
   * Index 12: Developer Contract/address  
   */
  address[13] public contracts; 

  mapping(uint256 => Proposal) public proposals;// Proposal ID => Proposal
  mapping(uint256 => Round) public rounds;
  
  Counters.Counter public roundCounter;

  uint256[10] public levelRewardWeights;
  uint256 public totalRewardWeight;

  uint256 public roundLenght;

  constructor(address[13] memory _contracts, uint256 _endOfTheFirstRound) {
    contracts = _contracts;  // Set the existing contracts
    rounds[roundCounter.current()].endingTime = _endOfTheFirstRound; // TEST -> Change it with unix value of Monday 00.00
    roundLenght = 7 days;
    getBackerRewards(rounds[roundCounter.current()]);     
  }

  function fundBoss(uint256 _levelNumber, uint256 _bossID, uint256 _fundAmount) public nonReentrant() returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 10, "Invalid level number!");

    Round storage round = rounds[roundCounter.current()];

    // If current round has ended, start the new one before funding
    if (block.timestamp > round.endingTime){
      startNextRound(round);
    }

    // Close funding in the last day of the round
    require(round.endingTime - 1 minutes  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this round. Maybe next time sweetie!"
    );
    // Check if the boss if it exists - If it has an owner, than it exists
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This Boss doesn't even exist!");
    // Get the funds!
    require(IERC20(contracts[11]).transferFrom(_msgSender(), address(this), _fundAmount), "Couldn't receive funds!");

    Election storage election = round.levels[_levelNumber].election;
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

  function defundBoss(uint256 _levelNumber, uint256 _bossID, uint256 _withdrawAmount) public nonReentrant() returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 10, "Invalid level number!");
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This Boss doesn't even exist!");
    
    Round storage round = rounds[roundCounter.current()];

    require(round.endingTime - 1 minutes  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this round. Too late sweetie!"
    );

    Election storage election = round.levels[_levelNumber].election;
    require(election.isCandidate[_bossID] == true, "This Boss is not even a candidate!");
    require(election.backerFunds[_bossID][_msgSender()] >= _withdrawAmount, "You can't withdraw more than you deposited!");

    // If everything goes well, subtract funds
    election.candidateFunds[_bossID] -= _withdrawAmount;
    election.backerFunds[_bossID][_msgSender()] -= _withdrawAmount;

    require(IERC20(contracts[11]).transfer(_msgSender(), _withdrawAmount), "Something went wrong while you're trying to withdraw!");

    return true;
  }

  function startNextRound(Round storage _currentRound) internal {
    // Iterate through all 10 level
    for (uint i = 0; i < 10; i++){
      Election storage election = _currentRound.levels[i].election;

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
          _currentRound.levels[i].playerReward = election.candidateFunds[election.candidateIDs[k]];
        }
        else{          
          burnAmount += election.candidateFunds[election.candidateIDs[k]];
        } 
      }
      // Burn them all!
      (bool txSuccess0, ) = address(contracts[11]).call(abi.encodeWithSignature("burn(uint256)", burnAmount));
      require(txSuccess0, "Burn tx has failed!");  

      // Record the Rekt
      (bool txSuccess1, ) = address(contracts[0]).call(abi.encodeWithSignature("bossRekt(uint256)", election.winnerID));
      require(txSuccess1, "Rekt record tx has failed!");
    }

    // Now we have burnt the losers' funds and save the winner's balance. Time to start next Round!
    uint256 previousTime = _currentRound.endingTime;
    roundCounter.increment();
    rounds[roundCounter.current()].endingTime = previousTime + roundLenght;
    getBackerRewards(rounds[roundCounter.current()]);
  }

  function claimPlayerReward(bytes32[] calldata _merkleProof, uint256 _roundNumber) public {
    require(block.timestamp > rounds[_roundNumber].endingTime, "Wait for the end of the round!");
    require(rounds[_roundNumber].endingTime != 0, "Invalied round number!"); // If there is no end time

    Round storage round = rounds[_roundNumber];
    address sender = _msgSender();
    
    require(!round.isPlayerClaimed[sender], "Dude! You have already claimed your reward! Why too aggressive?");
    round.isPlayerClaimed[sender] = true;  // Save as claimed

    // Check all the levels and sum up the rewards if any
    uint256 reward;

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i]; // Get the level

      // Check the merkle tree to validate the sender has played this level
      bytes32 leaf = keccak256(abi.encodePacked(sender));
      if (MerkleProof.verify(_merkleProof, level.merkleRoot, leaf)){  // if played, collect the reward
        reward += level.playerReward / level.totalNumberOfPlayer;
      }
    }

    require(reward > 0, "You have no reward to claim bro, sorry!");
    require(IERC20(contracts[11]).transfer(sender, reward), "Something went wrong while you're trying to get your reward!");
  }
  
  function claimBackerReward(uint256 _roundNumber) public {
    require(block.timestamp > rounds[_roundNumber].endingTime, "Wait for the end of the round!");
    require(rounds[_roundNumber].endingTime != 0, "Invalied round number!");

    Round storage round = rounds[_roundNumber];
    address sender = _msgSender();
    
    require(!round.isBackerClaimed[sender], "Dude! You have already claimed your reward! Why too aggressive?");
    round.isBackerClaimed[sender] = true;  // Save as claimed

    // Check all the levels and sum up the rewards if any
    uint256 reward;

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i];     // Get the level
      Election storage election = level.election; // Get the election

      // Collect the reward from this level's election
      // Formula: rewardAmount = backerReward * backerfund(sender's on the winner Boss) / total fund (on the winner Boss)
      reward += level.backerReward * 
        election.backerFunds[election.winnerID][sender] / election.candidateFunds[election.winnerID]
      ;
    }

    require(IERC20(contracts[11]).transfer(sender, reward), "Something went wrong while you're trying to get your reward!");
  }

  function getPlayerRewards(bytes32[] calldata _merkleProof, uint256 _roundNumber) public view returns (uint256[10] memory) {
    require(block.timestamp > rounds[_roundNumber].endingTime, "Wait for the end of the round!");
    require(rounds[_roundNumber].endingTime != 0, "Invalied round number!"); // If there is no end time

    uint256[10] memory rewards;

    Round storage round = rounds[_roundNumber];
    address sender = _msgSender();

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i]; // Get the level

      // Check the merkle tree to validate the sender has played this level
      bytes32 leaf = keccak256(abi.encodePacked(sender));
      if (MerkleProof.verify(_merkleProof, level.merkleRoot, leaf)){  // if played, get the reward
        rewards[i] = level.playerReward / level.totalNumberOfPlayer;
      }
    }

    return rewards;
  }

  function getBackerRewards(uint256 _roundNumber) public view returns (uint256[10] memory) {
    require(block.timestamp > rounds[_roundNumber].endingTime, "Wait for the end of the round!");
    require(rounds[_roundNumber].endingTime != 0, "Invalied round number!"); // If there is no end time

    uint256[10] memory rewards;

    Round storage round = rounds[_roundNumber];
    address sender = _msgSender();

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i];     // Get the level
      Election storage election = level.election; // Get the election

      // Collect the reward from this level's election
      // Formula: rewardAmount = backerReward * backerfund(sender's on the winner Boss) / total fund (on the winner Boss)
      rewards[i] = level.backerReward * 
        election.backerFunds[election.winnerID][sender] / election.candidateFunds[election.winnerID]
      ;
    }

    return rewards;
  }

  function returnMerkleRoot(uint256 _roundNumber, uint256 _levelNumber) public view returns (bytes32) {
    return rounds[_roundNumber].levels[_levelNumber].merkleRoot;
  }

  function getBackerRewards(Round storage _round) internal {
    // Get the backer rewards from token
    (bool txSuccess, bytes memory returnData) = contracts[11].call(abi.encodeWithSignature("backerMint()"));
    require(txSuccess, "Transaction has failed to get backer rewards from Token contract!");
    (_round.roundRewards) = abi.decode(returnData, (uint256));

    // Distribute it according to level weights
    for (uint256 i = 0; i < 10; i++) {
      _round.levels[i].backerReward = _round.roundRewards * levelRewardWeights[i] / totalRewardWeight;
    }
  }

  function updateLevelRewardRates(uint256 _level, uint256 _newWeight) public {
    require(_msgSender() == contracts[5], "Only the Executors can update the level reward rates!!");
    require(_level >= 0 && _level < 10, "Dude! Check the level number! It can be 0 to 12!");

    // Update total weight
    if (levelRewardWeights[_level] > _newWeight)
      totalRewardWeight -= levelRewardWeights[_level] - _newWeight;
    else
      totalRewardWeight += _newWeight - levelRewardWeights[_level];
    
    // Update level weight
    levelRewardWeights[_level] = _newWeight;
  }

  function getCurrentRoundNumber() public returns (uint256) {
    Round storage round = rounds[roundCounter.current()];

    // If current round has ended, start the new one before funding
    if (block.timestamp > round.endingTime){
      startNextRound(round);
    }

    return roundCounter.current();
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Rent contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
      Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypeIndex)
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

    require(proposal.updateCode == 1 && !proposal.isExecuted, "Wrong proposal ID");
    
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

  function proposeFunctionsProposalTypesUpdate(uint256 _newTypeIndex) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newTypeIndex != proposalTypeIndex, "Index is already the same!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Rent contract, updating index of proposal type to ", 
      Strings.toHexString(_newTypeIndex), " from ", Strings.toHexString(proposalTypeIndex), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
        abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypeIndex)
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Get data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].newUint = _newTypeIndex;
  }

  function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");

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
      proposalTypeIndex = proposal.newUint;

    proposal.isExecuted = true;
  }
}