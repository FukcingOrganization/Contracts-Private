// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
  * @notice
  * -> Fukcing community contract mints its allocation from fukcing token contract. 
  *
  * -> Executers propose a reward distribution to fukcing DAO. Receivers can claim
  * their rewards once its approved by the DAO.
  *
  * -> The length of the reward distribution proposals differ according to amount
  * of reward. It can be normal, high, or extreme amount of reward.
  *
  * -> Executers can propose to update contract addresses, proposal types, high reward
  * limit, and extreme reward limit.
  */

/**
  * @author Bora
  */
contract FukcingCommunity is Context {

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
  
  struct MerkleReward {
    bool approved;
    uint256 totalReward;
    uint256[] rewards;
    bytes32[] roots;
    
    mapping(address => bool) isClaimed;
  }

  struct Reward {
    bool approved;
    uint256 totalReward;
    uint256[] rewards;
    address[] addresses;
    
    mapping(address => bool) isClaimed;
  }

  mapping(uint256 => Proposal) public proposals;          // proposalID => Proposal
  mapping(uint256 => Reward) public rewards;              // Reward ID => Merkle Reward
  mapping(uint256 => MerkleReward) public merkleRewards;  // Merkle Reward ID => Merkle Reward

  /**
   * contracts' Indexes with corresponding meaning
   *  
   * Index 0: Boss Contract                // Proposal ID Tracker (PID) : 0
   * Index 1: Clan Contract                // PID: 1
   * Index 2: ClanLicence Contract         // PID: 2
   * Index 3: Community Contract           // PID: 3
   * Index 4: DAO Contract                 // PID: 4
   * Index 5: Executor Contract            // PID: 5
   * Index 6: Items Contract               // PID: 6
   * Index 7: Lord Contract                // PID: 7
   * Index 8: Rent Contract                // PID: 8
   * Index 9: Seance Contract              // PID: 9
   * Index 10: Staking Contract            // PID: 10
   * Index 11: Token Contract              // PID: 11
   * Index 12: Developer Contract/address  // PID: 12
   */
  address[13] public contracts;

  /**
   * proposalTypes's Indexes with corresponding meaning
   *  
   * Index 0: Less important proposals
   * Index 1: Moderately important proposals
   * Index 2: Highly important proposals
   * Index 3: MAX SUPPLY CHANGE PROPOSAL
   */
  uint256[4] public proposalTypes;

  uint256 public totalBalance;
  uint256 public rewardBalance;
  uint256 public highRewardLimit;
  uint256 public extremeRewardLimit;

  constructor() {
    highRewardLimit = 66666 ether;     // 66k token
    extremeRewardLimit = 666666 ether; // 666k token
  }

  function mintToken() public {
    require(_msgSender() == contracts[5], "You are not a fukcing executer!");
    
    (bool txSuccess, bytes memory returnData) = contracts[11].call(abi.encodeWithSignature("communityMint()"));
    require(txSuccess, "Transaction has failed to mint tokens!");

    (uint256 newTokens) = abi.decode(returnData, (uint256));
    totalBalance += newTokens;
  }

  function claimReward(uint256 _proposalID) public {
    Reward storage reward = rewards[_proposalID];
    require(reward.isClaimed[_msgSender()] == false, "Dude, you have already claimed your shit. So back off!");

    if (reward.approved == false) {
      updateRewardStatus(_proposalID);
    }
    require(reward.approved, "This reward is not approved by fukcing DAO. Sorry!");

    // Find the reward of caller
    uint256 receiverReward;
    for (uint i = 0; i < reward.addresses.length; i++){
      if (reward.addresses[i] == _msgSender()){
        receiverReward = reward.rewards[i];
        break;
      }
    }
    require(receiverReward > 0, "Dude, you have no reward. Check your proposal ID!");

    // If the caller has reward, save it and send it - contracts[11] is the token contract
    reward.isClaimed[_msgSender()] = true;
    reward.totalReward -= receiverReward;   // Keep track how much left
    ERC20(contracts[11]).transfer(_msgSender(), receiverReward);
  }

  // totalReward variable makes sure no more than approved reward can be claimed since merkletree doesn't provide it natively.
  function claimMerkleReward(uint256 _proposalID, bytes32[] calldata _merkleProof) public {
    MerkleReward storage mReward = merkleRewards[_proposalID];
    require(mReward.isClaimed[_msgSender()] == false, "Dude, you have already claimed your shit. So back off!");
    require(mReward.totalReward > 0, 
      "Everyone claimed all rewards. If you think there is a problem, reach out the fukcing executers!"
    );

    if (mReward.approved == false) {
      updateRewardStatus(_proposalID);
    }
    require(mReward.approved, "This merkle reward is not approved by fukcing DAO. Sorry!");

    // Find the reward of caller
    uint256 receiverReward = getMerkleReward(_merkleProof, mReward);
    require(receiverReward > 0, "Dude, you have no reward. Check your proposal ID!");

    // If the caller has reward, save it and send it - contracts[11] is the token contract
    mReward.isClaimed[_msgSender()] = true;
    mReward.totalReward -= receiverReward;   // Keep track how much left
    ERC20(contracts[11]).transfer(_msgSender(), receiverReward);
  }

  function getMerkleReward(bytes32[] calldata _merkleProof, MerkleReward storage mReward) internal view returns (uint256) {
    uint256 receiverReward;
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    
    // Search in all roots
    for (uint256 i = 0; i < mReward.roots.length; i++){

      // If the proof valid for this index, get the reward for this index
      if (MerkleProof.verify(_merkleProof, mReward.roots[i], leaf)){
          receiverReward = mReward.rewards[i];
          break;
      }
    }

    return receiverReward;
  }
  
  // updateCode helps to avoid random approved proposals to approve actual proposal!
  function updateRewardStatus(uint256 _proposalID) public {
    // Substract the claimed reward from rewardBalance
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 3, "Wrong proposal ID");
    require(proposal.isExecuted == false, "This proposal has already executed!");

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

    // if the current one is approved, We approve both merkleRewards and rewards.
    // Since its rewards will be empty, It doesn't matter for other reward mapping to get approved as well!
    if (proposal.status == Status.Approved){      
      rewards[_proposalID].approved = true;
      merkleRewards[_proposalID].approved = true;
    }
    // If the proposal denied, then release the funds. One of the mappings will have 0 totalReward. No panic!
    else {
      rewardBalance -= rewards[_proposalID].totalReward;
      rewardBalance -= merkleRewards[_proposalID].totalReward;
    }

    proposal.isExecuted = true;
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * setReward and setMerkleReward -> Code: 3
   * highRewardLimit -> Code: 4
   * extremeRewardLimit -> Code: 5
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Community contract, updating contract address of index ", Strings.toHexString(_contractIndex), 
      " to ", Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
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

  function proposeProposalTypesUpdate(uint256 _proposalIndex, uint256 _newType) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Community contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), 
      " to ", Strings.toHexString(_newType), " from ", Strings.toHexString(proposalTypes[_proposalIndex]), "."
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
      proposalTypes[proposal.index] = proposal.newUint;

    proposal.isExecuted = true;
  }

  function setReward(address[] memory _receivers, uint256[] memory _rewards) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    // Calculate the total reward
    uint256 totalReward;
    for (uint i = 0; i < _rewards.length; i++){
      totalReward += _rewards[i];
    }

    require(totalReward <= totalBalance - rewardBalance, "You have exceeded the avaliable balance to spend!");
    // Reserve the reward balance so we can't propose to spend more
    rewardBalance += totalReward;

    string memory proposalDescription = string(abi.encodePacked(
        "A total of ", Strings.toHexString(totalReward), " community reward to ", 
        Strings.toHexString(_receivers.length), " address(es)"
    ));

    // Set proposal type according to importance of the reward amount
    uint256 propType;
    if (totalReward > extremeRewardLimit)
      propType = 2;
    else if (totalReward > highRewardLimit)
      propType = 1;

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
        abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, propType)
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the proposal and rewards
    proposals[propID].updateCode = 3;
    rewards[propID].totalReward = totalReward;
    rewards[propID].addresses = _receivers;
    rewards[propID].rewards = _rewards;
  }

  function setMerkleReward(bytes32[] memory _roots, uint256[] memory _rewards, uint256 _totalReward) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_totalReward <= totalBalance - rewardBalance, "You have exceeded the avaliable balance to spend!");

    // Reserve the reward balance so we can't propose to spend more
    rewardBalance += _totalReward;

    string memory proposalDescription = string(abi.encodePacked(
        "A total of ", Strings.toHexString(_totalReward), " community reward to ", 
        Strings.toHexString(_roots.length), " root(s)"
    )); 

    // Set proposal type according to importance of the reward amount
    uint256 propType;
    if (_totalReward > extremeRewardLimit)
      propType = 2;
    else if (_totalReward > highRewardLimit)
      propType = 1;

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
       abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, propType)
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the proposal and rewards
    proposals[propID].updateCode = 3;
    merkleRewards[propID].totalReward = _totalReward;
    merkleRewards[propID].roots = _roots;
    merkleRewards[propID].rewards = _rewards;
  }

  function proposeHighRewarLimitSet(uint256 _newLimit) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    string memory proposalDescription = string(abi.encodePacked(
        "In Fukcing Community contract, increasing High Reward Limit to ", 
        Strings.toHexString(_newLimit), " from ", Strings.toHexString(highRewardLimit), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
         abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 4;
    proposals[propID].newUint = _newLimit;
  }

  function executeHighRewarLimitSetProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 4 && !proposal.isExecuted, "Wrong proposal ID");

    // Get the proposal result from DAO
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
        abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
    );
    require(txSuccess, "Transaction failed to retrieve DAO result!");
    (uint256 statusNum) = abi.decode(returnData, (uint256));

    // Save the result here
    proposal.status = Status(statusNum);

    // Check if it is finalized or not
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved)
      highRewardLimit = proposal.newUint;

    proposal.isExecuted = true;
  }
  
  function proposeExtremeRewarLimitSet(uint256 _newLimit) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    string memory proposalDescription = string(abi.encodePacked(
        "In Fukcing Community contract, increasing Extreme Reward Limit to ", 
        Strings.toHexString(_newLimit), " from ", Strings.toHexString(extremeRewardLimit), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
         abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 5;
    proposals[propID].newUint = _newLimit;
  }

  function executeExtremeRewarLimitSetProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 5 && !proposal.isExecuted, "Wrong proposal ID");

    // Get the proposal result from DAO
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
        abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
    );
    require(txSuccess, "Transaction failed to retrieve DAO result!");
    (uint256 statusNum) = abi.decode(returnData, (uint256));

    // Save the result here
    proposal.status = Status(statusNum);

    // Check if it is finalized or not
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved)
      extremeRewardLimit = proposal.newUint;

    proposal.isExecuted = true;
  }
}