// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
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


interface IDAO {
  function newProposal(string memory _description, uint256 _proposalType) external returns(uint256);
  function proposalResult(uint256 _proposalID) external returns(uint256);
}

interface IBoss {
  function bossRekt(uint256 _tokenID) external;
}

interface IToken {
  function backerMint() external returns (uint256);
}

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
    mapping(uint256 => uint256) numberOfBackers; // candidate ID => number of backers
    uint256 winnerID;
  }

  struct Level{
    Election election;
    uint256 playerReward;
    uint256 backerReward;
    uint256 numberOfPlayers;
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

  uint256 public roundLength;

  bool isGenesisCallExecuted;

  constructor(address[13] memory _contracts, uint256 _endOfTheFirstRound, uint256[10] memory _levelWeights, uint256 _totalWeight) {
    contracts = _contracts;  // Set the existing contracts
    roundCounter.increment(); // Start the rounds from 1
    rounds[roundCounter.current()].endingTime = _endOfTheFirstRound; // TEST -> Change it with unix value of Monday 00.00
    roundLength = 1 days; // TEST: 7 days;
    levelRewardWeights = _levelWeights;
    totalRewardWeight = _totalWeight;
  }

  function viewLevel(uint256 _roundNumber, uint256 _levelNumber) public view returns(uint256, uint256, uint256, bytes32){
    Level storage level = rounds[_roundNumber].levels[_levelNumber];

    return (level.playerReward, level.backerReward, level.numberOfPlayers, level.merkleRoot); 
  }

  function viewElection(uint256 _roundNumber, uint256 _levelNumber) public view returns(uint256[] memory, uint256){
    Level storage level = rounds[_roundNumber].levels[_levelNumber];

    return (level.election.candidateIDs, level.election.winnerID); 
  }

  function isCandidate(uint256 _roundNumber, uint256 _levelNumber, uint256 _candidateID) public view returns(bool){
    return rounds[_roundNumber].levels[_levelNumber].election.isCandidate[_candidateID];
  }

  function viewCandidateFunds(uint256 _roundNumber, uint256 _levelNumber, uint256 _candidateID) public view returns(uint256){
    return rounds[_roundNumber].levels[_levelNumber].election.candidateFunds[_candidateID];
  }

  function viewBackerFunds(uint256 _roundNumber, uint256 _levelNumber, uint256 _candidateID, address _backer) public view returns(uint256){
    return rounds[_roundNumber].levels[_levelNumber].election.backerFunds[_candidateID][_backer];
  }

  function genesisCall() public {
    require(!isGenesisCallExecuted, "The Genesis Call is already executed once!");
    isGenesisCallExecuted = true;
    getBackerRewards(rounds[roundCounter.current()]);
  }

  function DEBUG_setContract(address _contractAddress, uint256 _index) public {
    contracts[_index] = _contractAddress;
  }

  function DEBUG_setContracts(address[13] memory _contracts) public {
    contracts = _contracts;
  }

  function fundBoss(uint256 _levelNumber, uint256 _bossID, uint256 _fundAmount) public nonReentrant() returns (bool) {
    Round storage round = rounds[roundCounter.current()];

    // If current round has ended, start the new one before funding
    if (block.timestamp > round.endingTime){
      startNextRound(round);
    }

    // Close funding in the last day of the round to avoid mistakenly funding
    require(round.endingTime - 1 hours  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this round. Maybe next time sweetie!"
    );
    require(_levelNumber < 10, "Invalid level number!");  // 0 to 9
    // Check if the boss if it exists - If it has an owner, than it exists
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This Boss doesn't even exist!");
    // Get the funds!
    require(IERC20(contracts[11]).transferFrom(_msgSender(), address(this), _fundAmount), "Couldn't receive funds!");

    Election storage election = round.levels[_levelNumber].election;
    // If the boss is not a candidate yet, make it a candidate for this level
    if (!election.isCandidate[_bossID]){
      election.isCandidate[_bossID] = true;
      election.candidateIDs.push(_bossID);
    }
    // If the backer funding this lord for the first time, increase the number of backers of this boss
    if (election.backerFunds[_bossID][_msgSender()] == 0) { election.numberOfBackers[_bossID]++; }

    // Add funds
    election.candidateFunds[_bossID] += _fundAmount;
    election.backerFunds[_bossID][_msgSender()] += _fundAmount;

    return true;    
  }

  function defundBoss(uint256 _levelNumber, uint256 _bossID, uint256 _withdrawAmount) public nonReentrant() returns (bool) {
    require(_levelNumber >= 0 && _levelNumber < 10, "Invalid level number!");
    require(IERC721(contracts[0]).ownerOf(_bossID) != address(0), "This Boss doesn't even exist!");
    
    Round storage round = rounds[roundCounter.current()];

    // If current round has ended, start the new one before funding
    if (block.timestamp > round.endingTime){
      startNextRound(round);
    }

    // Close funding in the last day of the round to avoid mistakenly funding
    require(round.endingTime - 1 hours  > block.timestamp, // TEST -> Change it with 1 day
      "The funding round is closed for this round. Too late sweetie!"
    );

    Election storage election = round.levels[_levelNumber].election;
    require(election.isCandidate[_bossID], "This Boss is not even a candidate!");
    require(election.backerFunds[_bossID][_msgSender()] >= _withdrawAmount, "You can't withdraw more than you deposited!");

    // If everything goes well, subtract funds
    election.candidateFunds[_bossID] -= _withdrawAmount;
    election.backerFunds[_bossID][_msgSender()] -= _withdrawAmount;

    // If no bakcer funds left, decrease the number of backers of this boss
    if (election.backerFunds[_bossID][_msgSender()] == 0) { election.numberOfBackers[_bossID]--; }

    require(IERC20(contracts[11]).transfer(_msgSender(), _withdrawAmount), "Something went wrong while you're trying to withdraw!");

    return true;
  }

  function startNextRound(Round storage _currentRound) internal {
    // Iterate through all 10 level
    for (uint i = 0; i < 10; i++){
      Election storage election = _currentRound.levels[i].election;

      // If there is only 1 candidate, take it as the winner
      if (election.candidateIDs.length == 1){        
        election.winnerID = election.candidateIDs[0];
        _currentRound.levels[i].playerReward = election.candidateFunds[election.candidateIDs[0]];
      }
      // But if there is more than 1 candidate, find the Winner
      else if (election.candidateIDs.length > 1) {
        election.winnerID = election.candidateIDs[0];

        for (uint j = 1; j < election.candidateIDs.length; j++){  // all candidates
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
        ERC20Burnable(contracts[11]).burn(burnAmount);

        // Record the Rekt
        IBoss(contracts[0]).bossRekt(election.winnerID);
      }
    }

    // Now we have burnt the losers' funds and save the winner's balance. Time to start next Round!
    uint256 previousTime = _currentRound.endingTime;
    roundCounter.increment();
    rounds[roundCounter.current()].endingTime = previousTime + roundLength;
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
        reward += level.playerReward / level.numberOfPlayers;
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

    for (uint256 i = 0; i < 10; i++){
      Level storage level = round.levels[i];     // Get the level
      Election storage election = level.election; // Get the election

      // Collect the reward from this level's election
      // Formula: rewardAmount = backerReward * backerfund(sender's on the winner Boss) / total fund (on the winner Boss)
      if (election.backerFunds[election.winnerID][sender] > 0) { // If there the sender has backed the winner
        reward += level.backerReward * 
          election.backerFunds[election.winnerID][sender] / election.candidateFunds[election.winnerID]
        ;
      }
    }

    require(IERC20(contracts[11]).transfer(sender, reward), "Something went wrong while you're trying to get your reward!");
  }

  function viewPlayerRewards(bytes32[] calldata _merkleProof, uint256 _roundNumber) public view returns (
    uint256[10] memory, // Player's rewards
    uint256[10] memory, // Total player rewards
    uint256[10] memory  // Number of players
  ) {
    require(block.timestamp > rounds[_roundNumber].endingTime, "Wait for the end of the round!");
    require(rounds[_roundNumber].endingTime != 0, "Invalied round number!"); // If there is no end time

    uint256[10] memory playerRewards;
    uint256[10] memory totalPlayerRewards;
    uint256[10] memory numOfPlayers;

    Round storage round = rounds[_roundNumber];
    address sender = _msgSender();

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i]; // Get the level

      totalPlayerRewards[i] = level.playerReward;
      numOfPlayers[i] = level.numberOfPlayers;

      // Check the merkle tree to validate the sender has played this level
      bytes32 leaf = keccak256(abi.encodePacked(sender));
      if (MerkleProof.verify(_merkleProof, level.merkleRoot, leaf)){  // if played, get the reward
        playerRewards[i] = level.playerReward / level.numberOfPlayers;
      }
    }

    return (playerRewards, totalPlayerRewards, numOfPlayers);
  }

  function viewBackerRewardInfo(uint256 _roundNumber, address _backer) public view returns (
    uint256[10] memory, // Backer Rewards
    uint256[10] memory, // Backer's Funds
    uint256[10] memory, // Total Funds
    uint256[10] memory  // Number of backers
  ) {
    require(_roundNumber < roundCounter.current(), "You can't retrive values from an ongoing round!"); // If there is no end time

    uint256[10] memory rewards;
    uint256[10] memory backerFunds;
    uint256[10] memory totalFunds;
    uint256[10] memory numOfBackers;

    Round storage round = rounds[_roundNumber];

    for (uint i = 0; i < 10; i++){
      Level storage level = round.levels[i];      // Get the level
      Election storage election = level.election; // Get the election

      backerFunds[i] = election.backerFunds[election.winnerID][_backer];
      totalFunds[i] = election.candidateFunds[election.winnerID];      
      rewards[i] = level.backerReward * backerFunds[i] / totalFunds[i];
      numOfBackers[i] = election.numberOfBackers[election.winnerID];
    }

    return (rewards, backerFunds, totalFunds, numOfBackers);
  }

  function viewCurrentBackerRewards() public view returns (uint256[10] memory) {
    uint256[10] memory backerFunds;

    Round storage round = rounds[roundCounter.current()];

    for (uint i = 0; i < 10; i++){
      backerFunds[i] = round.levels[i].backerReward;
    }

    return backerFunds;
  }

  function returnMerkleRoot(uint256 _roundNumber, uint256 _levelNumber) public view returns (bytes32) {
    return rounds[_roundNumber].levels[_levelNumber].merkleRoot;
  }

  function getBackerRewards(Round storage _round) internal {
    // Get the backer rewards
    _round.roundRewards = IToken(contracts[11]).backerMint();

    // Distribute it according to level weights
    for (uint256 i = 0; i < 10; i++) {
      _round.levels[i].backerReward = _round.roundRewards * levelRewardWeights[i] / totalRewardWeight;
    }
  }

  function updateLevelRewardRates(uint256[10] memory _newLevelWeights, uint256 _newTotalWeight) public {
    require(_msgSender() == contracts[5], "Only the Executors can update the level reward rates!!");

    levelRewardWeights = _newLevelWeights;
    totalRewardWeight = _newTotalWeight;
  }

  function getCurrentRoundNumber() public returns (uint256) {
    Round storage round = rounds[roundCounter.current()];

    // If current round has ended, start the new one before funding
    if (block.timestamp > round.endingTime){
      startNextRound(round);
    }

    return roundCounter.current();
  }

  function viewRoundNumber() public view returns (uint256) {
    return roundCounter.current();
  }

  function setPlayerMerkleRootAndNumber(uint256 _round, uint256 _level,  bytes32 _root, uint256 _numberOfPlayers) public {    
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    rounds[_round].levels[_level].merkleRoot = _root;
    rounds[_round].levels[_level].numberOfPlayers = _numberOfPlayers;
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

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, proposalTypeIndex);

    // Save data to the proposal
    proposals[propID].updateCode = 1;
    proposals[propID].index = _contractIndex;
    proposals[propID].newAddress = _newAddress;
  }

  function executeContractAddressUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 1 && !proposal.isExecuted, "Wrong proposal ID");
    
    // Get the result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Wait for the current one to finalize
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

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

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, proposalTypeIndex);

    // Get data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].newUint = _newTypeIndex;
  }

  function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");

    // Get its result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Wait for the current one to finalize
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if the current one is approved, apply the update the state
    if (proposal.status == Status.Approved)
      proposalTypeIndex = proposal.newUint;

    proposal.isExecuted = true;
  }
}