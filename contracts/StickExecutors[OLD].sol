// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
  * -> Update: signal time
  */

 
/**
 * @notice
 * -> Executors executes update proposals to maintain the sustainablity and balance in Stick Fight.
 * -> At least half of the executors should signal to propose a new proposal within the signal time
 * -> SDAO can hire or fire executors.
 */

/**
 * @author Bora
*/

interface IBaseUpdate {
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) external;
  function proposeFunctionsProposalTypesUpdate(uint256 _functionIndex, uint256 _newIndex) external;
}

interface IBoss {
  function proposeMintCostUpdate(uint256 _newCost) external;
}

interface IClan {
  function proposeMaxPointToChangeUpdate(uint256 _newMaxPoint) external;
  function proposeCooldownTimeUpdate(uint256 _newCooldownTime) external;
  function proposeMinBalanceToPropClanPointUpdate(uint256 _newAmount) external;
  function giveClanPoint(uint256 _clanID, uint256 _point, bool _isDecreasing) external;
}

interface IClanLicense {
  function proposeMintCostUpdate(uint256 _newMintCost) external;
}

interface ICommunity {
  function proposeReward(address[] memory _receivers, uint256[] memory _rewards) external;
  function proposeMerkleReward(bytes32[] memory _roots, uint256[] memory _rewards, uint256 _totalReward) external;
  function proposeHighRewarLimitSet(uint256 _newLimit) external;
  function proposeExtremeRewardLimitSet(uint256 _newLimit) external;
}

interface IDAO {
  function newProposal(string memory _description, uint256 _proposalType) external returns(uint256);
  function proposalResult(uint256 _proposalID) external returns(uint256);
  function getMinBalanceToPropose() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);

  function proposeMinBalanceToPropUpdate(uint256 _newAmount) external;
  function proposeNewProposalType(
    uint256 _length, 
    uint256 _requiredApprovalRate, 
    uint256 _requiredTokenAmount, 
    uint256 _requiredParticipantAmount
  ) external;
  function proposeProposalTypeUpdate(
    uint256 _proposalTypeNumber, 
    uint256 _newLength, 
    uint256 _newRequiredApprovalRate, 
    uint256 _newRequiredTokenAmount, 
    uint256 _newRequiredParticipantAmount
  ) external;
  function proposeNewTokenSpending(
    address _tokenContractAddress, 
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending
  ) 
  external;
  function proposeNewCoinSpending(
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending) 
  external;
}

interface IItems {
  function proposeMintCostUpdate(uint256 _itemID, uint256 _newCost) external;
  function proposeItemActivationUpdate(uint256 _itemID, bool _activationStatus) external;
  function setTokenURI(uint256 tokenID, string memory tokenURI) external;
}

interface ILord {
  function proposeBaseTaxRateUpdate(uint256 _newBaseTaxRate) external;
  function proposeTaxChangeRateUpdate(uint256 _newTaxChangeRate) external;
  function proposeRebellionLenghtUpdate(uint256 _newRebellionLenght) external;
  function proposeSignalLenghtUpdate(uint256 _newSignalLenght) external;
  function proposeVictoryRateUpdate(uint256 _newVictoryRate) external;
  function proposeWarCasualtyRateUpdate(uint256 _newWarCasualtyRate) external;
  function setBaseURI(string memory _newURI) external;
}

interface IToken {
  function proposeMintPerSecondUpdate(uint256 _mintIndex, uint256 _newMintPerSecond) external;
  function snapshot() external;
  function pause() external;
  function unpause() external;
  function stakingMint() external returns (uint256);
  function daoMint(uint256 _amount) external returns (bool);
  function developmentMint(uint256 _amount) external returns (bool);
  function communityMint(uint256 _amount) external returns (bool);
}

interface IRound {
  function setPlayerMerkleRoot(uint256 _round, uint256 _level, bytes32 _root) external;
}

contract StickExecutors is Context, AccessControl {
  using Counters for Counters.Counter; 

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

  struct Signal {
    uint256 expires;
    uint256 signalTrackerID;
    uint256 numOfSignals;
    mapping(address => bool) isSignaled;

    uint256 contractIndex;
    uint256 subjectIndex;

    bytes32 propBytes32;
    bytes32[] propBytes32Array;
    string propString;
    bool propBool;
    address propAddress;
    address[] propAddresses;
    uint256 propUint;
    uint256[] propUintArray;
    uint256 propUint1;
    uint256 propUint2;
    uint256 propUint3;
    uint256 propUint4;
  }

  Counters.Counter internal signalCounter;

  mapping(uint256 => Proposal) public proposals;  // proposal ID => Proposal
  mapping(uint256 => Signal) public signals;      // function ID => Signal
  mapping(address => bool) public isExecutor;     // The executors

  bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

  /** 
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

  uint256 public executorProposalTypeIndex;

  uint256 public numOfExecutors;
  uint256[100] public signalTrackerID; // TEST: Set it the number of signals
  uint256 public signalTime;

  constructor() {
    // Grant the deployer as an executor
    _grantRole(EXECUTOR_ROLE, _msgSender());
    isExecutor[_msgSender()] = true;
    numOfExecutors++;  

    // At least half of the executor should signal within (initially) 1 day to execute a new proposal 
    signalTime = 5 minutes; // TEST: make it 1 days;        
    signalCounter.increment();  // Start the counter from 1
  } 

  function DEBUG_setContract(address _contractAddress, uint256 _index) public {
    contracts[_index] = _contractAddress;
  }

  function DEBUG_setContracts(address[13] memory _contracts) public {
    contracts = _contracts;
  }

  function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
    revert("DAO approval needed to grant a role!");
  }

  function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
    revert("DAO approval needed to revoke a role!");
  }

  function renounceRole(bytes32 role, address account) public virtual override {
    isExecutor[account] = false;
    numOfExecutors--;
    
    super.renounceRole(role, account);
  }

  /**
   * Signal Tracker IDs
   *


   * Absolutely *
   * Contract Address Update: 1
   * Creating Contract Address Update Proposal in other contracts: 2
   * Creating Functions Proposal Type Update Proposal in other contracts: 3
   * Creating DAO: Proposal Type Update Proposal: 15
   * Creating Lord: Base Tax Rate Update Proposal: 18
   * Creating Lord: Tax Change Rate Update Proposal: 19
   * Creating Lord: Rebellion Lenght Update Proposal: 20
   * Creating Lord: Victory Rate Update Proposal: 22
   * Creating Token: Mint Per Second Update Proposal: 24
   * Creating Token: Pause: 28
   * Creating Token: Unpause: 29
   * Creating Round: Set Players Root: 36
   * Creating Clan: Give Clan Points: 37


   * Maybe *

   * NO NEED * 
   * Creating Lord: Set Base URI: 34
   * Creating Item: Set Token URI: 35
   * Creating Clan: Max Point To Change Update Proposal: 5
   * Creating Clan: Cooldown Time Update Proposal: 6
   * Creating Clan License: Mint Cost Update Proposal: 7
   * Creating Community: Reward Proposal: 8
   * Creating Community: Merkle Reward Proposal: 9
   * Creating Community: High Reward Limit Set Proposal: 10
   * Creating Community: Extreme Reward Limit Set Proposal: 11
   * Creating DAO: New Token Spending Proposal: 25
   * Creating DAO: New Coin Spending Proposal: 26

   * Creating Boss: Mint Cost Update Proposal: 4
   * Creating DAO: Min Balance To Prop Update Proposal: 12
   * Creating Clan: Min Balance To Prop Clan Point Update Proposal: 13
   * Creating DAO: New Proposal Type Proposal: 14
   * Creating Item: Mint Cost Update Proposal: 16
   * Creating Item: Item Activation Update Proposal: 17
   * Creating Lord: Signal Lenght Update Proposal: 21
   * Creating Lord: War Casualty Rate Update Proposal: 23
   * Creating Token: Snapshot: 27
   * Creating Token: Staking Mint: 30
   * Creating Token: Dao Mint: 31
   * Creating Token: Development Mint: 32
   * Creating Token: Community Mint: 33
  */

  function updateContractAddress(uint256 _contractIndex, address _newAddress) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[1]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {
      require(_newAddress != address(0), "You can't set the address to null!");

      signalTrackerID[1] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[1]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 1;
      newSignal.contractIndex = _contractIndex;
      newSignal.propAddress = _newAddress;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      contracts[currentSignal.contractIndex]= currentSignal.propAddress;
      signalTrackerID[1] = 0; // To avoid further executions
    }       
  }
  
  function createContractAddressUpdateProposal(
    uint256 _contractIndex,  // Destination Contract address
    uint256 _subjectIndex,   // The address that we want to update in the destination contract. Same index as contracts
    address _newAddress      // New address
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[2]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {
      require(_newAddress != address(0), "You can't set the address to null!");

      signalTrackerID[2] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[2]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 2;
      newSignal.contractIndex = _contractIndex;
      newSignal.subjectIndex = _subjectIndex;
      newSignal.propAddress = _newAddress;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IBaseUpdate(contracts[currentSignal.contractIndex]).proposeContractAddressUpdate(
        currentSignal.subjectIndex, currentSignal.propAddress
      );
      signalTrackerID[2] = 0; // To avoid further executions
    }       
  }

  function createFunctionsProposalTypesUpdateProposal(
    uint256 _contractIndex, // Destination Contract address
    uint256 _subjectIndex,  // The Proposal Type Index that we want to update in the destination contract
    uint256 _newIndex       // New index
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[3]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[3] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[3]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 3;
      newSignal.contractIndex = _contractIndex;
      newSignal.subjectIndex = _subjectIndex;
      newSignal.propUint = _newIndex;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IBaseUpdate(contracts[currentSignal.contractIndex]).proposeFunctionsProposalTypesUpdate(
        currentSignal.subjectIndex, currentSignal.propUint
      );
      signalTrackerID[3] = 0; // To avoid further executions
    }       
  }

  
  function createBossMintCostUpdateProposal(uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[4]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[4] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[4]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 4;
      newSignal.propUint = _newCost;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IBoss(contracts[0]).proposeMintCostUpdate(currentSignal.propUint);
      signalTrackerID[4] = 0; // To avoid further executions
    }       
  }
  
  function createClanMaxPointToChangeUpdateProposal(uint256 _newMaxPoint) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[5]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[5] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[5]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 5;
      newSignal.propUint = _newMaxPoint;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IClan(contracts[1]).proposeMaxPointToChangeUpdate(currentSignal.propUint);
      signalTrackerID[5] = 0; // To avoid further executions
    }       
  }
  
  function createClanCooldownTimeUpdateProposal(uint256 _newCoolDownTime) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[6]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[6] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[6]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 6;
      newSignal.propUint = _newCoolDownTime;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IClan(contracts[1]).proposeCooldownTimeUpdate(currentSignal.propUint);
      signalTrackerID[6] = 0; // To avoid further executions
    }       
  }
  
  function createClanLicenseMintCostUpdateProposal(uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[7]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[7] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[7]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 7;
      newSignal.propUint = _newCost;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IClanLicense(contracts[2]).proposeMintCostUpdate(currentSignal.propUint);
      signalTrackerID[7] = 0; // To avoid further executions
    }       
  }
  
  function createCommunityRewardProposal(
    address[] memory _receivers,
    uint256[] memory _rewards
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[8]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[8] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[8]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 8;
      newSignal.propAddresses = _receivers;
      newSignal.propUintArray = _rewards;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ICommunity(contracts[3]).proposeReward(currentSignal.propAddresses, currentSignal.propUintArray);
      signalTrackerID[8] = 0; // To avoid further executions
    }       
  }
  
  function createCommunityMerkleRewardProposal(
    bytes32[] memory _roots, 
    uint256[] memory _rewards,
    uint256 _totalReward
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[9]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[9] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[9]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 9;
      newSignal.propBytes32Array = _roots;
      newSignal.propUintArray = _rewards;
      newSignal.propUint = _totalReward;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ICommunity(contracts[3]).proposeMerkleReward(
        currentSignal.propBytes32Array, currentSignal.propUintArray, currentSignal.propUint
      );
      signalTrackerID[9] = 0; // To avoid further executions
    }       
  }
  
  function createCommunityHighRewarLimitSetProposal(uint256 _newLimit) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[10]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[10] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[10]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 10;
      newSignal.propUint = _newLimit;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ICommunity(contracts[3]).proposeHighRewarLimitSet(currentSignal.propUint);
      signalTrackerID[10] = 0; // To avoid further executions
    }       
  }
  
  function createCommunityExtremeRewardLimitSetProposal(uint256 _newLimit) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[11]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[11] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[11]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 11;
      newSignal.propUint = _newLimit;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ICommunity(contracts[3]).proposeHighRewarLimitSet(currentSignal.propUint);      
      signalTrackerID[11] = 0; // To avoid further executions
    }       
  }
  
  function createDAOMinBalanceToPropUpdateProposal(uint256 _newAmount) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[12]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[12] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[12]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 12;
      newSignal.propUint = _newAmount;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IDAO(contracts[4]).proposeMinBalanceToPropUpdate(currentSignal.propUint);   
      signalTrackerID[12] = 0; // To avoid further executions
    }       
  }

  function createDAONewTokenSpendingProposal(
    address _tokenContractAddress, 
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[25]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[25] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[25]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 25;
      newSignal.propAddress = _tokenContractAddress;
      newSignal.propBytes32Array = _merkleRoots;
      newSignal.propUintArray = _allowances;
      newSignal.propUint = _totalSpending;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IDAO(contracts[4]).proposeNewTokenSpending(
        currentSignal.propAddress,
        currentSignal.propBytes32Array,
        currentSignal.propUintArray,
        currentSignal.propUint
      );   
      signalTrackerID[25] = 0; // To avoid further executions
    }       
  }

  function createDAONewCoinSpendingProposal(
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[26]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[26] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[26]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 26;
      newSignal.propBytes32Array = _merkleRoots;
      newSignal.propUintArray = _allowances;
      newSignal.propUint = _totalSpending;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IDAO(contracts[4]).proposeNewCoinSpending(
        currentSignal.propBytes32Array,
        currentSignal.propUintArray,
        currentSignal.propUint
      );  
      signalTrackerID[26] = 0; // To avoid further executions
    }       
  }
  
  
  function createDAONewProposalTypeProposal(
    uint256 _length, 
    uint256 _requiredApprovalRate, 
    uint256 _requiredTokenAmount, 
    uint256 _requiredParticipantAmount
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[14]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[14] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[14]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 14;
      newSignal.propUint1 = _length;
      newSignal.propUint2 = _requiredApprovalRate;
      newSignal.propUint3 = _requiredTokenAmount;
      newSignal.propUint4 = _requiredParticipantAmount;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IDAO(contracts[4]).proposeNewProposalType(
        currentSignal.propUint1,
        currentSignal.propUint2,
        currentSignal.propUint3,
        currentSignal.propUint4
      );
      signalTrackerID[14] = 0; // To avoid further executions
    }       
  }
  
  function createDAOProposalTypeUpdateProposal(
    uint256 _proposalTypeNumber, 
    uint256 _newLength, 
    uint256 _newRequiredApprovalRate, 
    uint256 _newRequiredTokenAmount, 
    uint256 _newRequiredParticipantAmount
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[15]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[15] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[15]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 15;
      newSignal.propUint = _proposalTypeNumber;
      newSignal.propUint1 = _newLength;
      newSignal.propUint2 = _newRequiredApprovalRate;
      newSignal.propUint3 = _newRequiredTokenAmount;
      newSignal.propUint4 = _newRequiredParticipantAmount;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IDAO(contracts[4]).proposeProposalTypeUpdate(
        currentSignal.propUint,
        currentSignal.propUint1,
        currentSignal.propUint2,
        currentSignal.propUint3,
        currentSignal.propUint4
      );
      signalTrackerID[15] = 0;  // To avoid further executions
    }       
  }
  
  function createClanMinBalanceToPropClanPointUpdateProposal(uint256 _newAmount) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[13]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[13] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[13]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 13;
      newSignal.propUint = _newAmount;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IClan(contracts[1]).proposeMinBalanceToPropClanPointUpdate(currentSignal.propUint);   
      signalTrackerID[13] = 0; // To avoid further executions
    }       
  }
  
  function createItemsMintCostUpdateProposal(uint256 _itemID, uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[16]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[16] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[16]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 16;
      newSignal.propUint = _itemID;
      newSignal.propUint1 = _newCost;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IItems(contracts[6]).proposeMintCostUpdate(currentSignal.propUint, currentSignal.propUint1);
      signalTrackerID[16] = 0; // To avoid further executions
    }       
  }
  
  function createItemActivationUpdateProposal(uint256 _itemID, bool _activationStatus) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[17]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[17] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[17]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 17;
      newSignal.propUint = _itemID;
      newSignal.propBool = _activationStatus;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IItems(contracts[6]).proposeItemActivationUpdate(currentSignal.propUint, currentSignal.propBool);
      signalTrackerID[17] = 0; // To avoid further executions
    }       
  }
  
  function createLordBaseTaxRateUpdateProposal(uint256 _newBaseTaxRate) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[18]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[18] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[18]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 18;
      newSignal.propUint = _newBaseTaxRate;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[18] = 0; // To avoid further executions
    }       
  }
  
  function createLordTaxChangeRateUpdateProposal(uint256 _newTaxChangeRate) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[19]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[19] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[19]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 19;
      newSignal.propUint = _newTaxChangeRate;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[19] = 0; // To avoid further executions
    }       
  }
  
  function createLordRebellionLenghtUpdateProposal(uint256 _newRebellionLenght) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[20]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[20] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[20]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 20;
      newSignal.propUint = _newRebellionLenght;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[20] = 0; // To avoid further executions
    }       
  }
  
  function createLordSignalLenghtUpdateProposal(uint256 _newSignalLenght) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[21]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[21] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[21]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 21;
      newSignal.propUint = _newSignalLenght;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[21] = 0; // To avoid further executions
    }       
  }
  
  function createLordVictoryRateUpdateProposal(uint256 _newVictoryRate) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[22]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[22] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[22]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 22;
      newSignal.propUint = _newVictoryRate;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[22] = 0; // To avoid further executions
    }       
  }
  
  function createWarLordCasualtyRateUpdateProposal(uint256 _newWarCasualtyRate) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[23]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[23] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[23]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 23;
      newSignal.propUint = _newWarCasualtyRate;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).proposeBaseTaxRateUpdate(currentSignal.propUint);
      signalTrackerID[23] = 0; // To avoid further executions
    }       
  }
  
  function createTokenMintPerSecondUpdateProposal(uint256 _mintIndex, uint256 _newMintPerSecond) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[24]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[24] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[24]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 24;
      newSignal.propUint = _mintIndex;
      newSignal.propUint1 = _newMintPerSecond;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).proposeMintPerSecondUpdate(currentSignal.propUint, currentSignal.propUint1);
      signalTrackerID[24] = 0; // To avoid further executions
    }       
  }

  function createTokenSnapshot() public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[27]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[27] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[27]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 27;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).snapshot();
      signalTrackerID[27] = 0; // To avoid further executions
    }       
  }

  function createTokenPause() public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[28]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[28] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[28]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 28;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).pause();
      signalTrackerID[28] = 0; // To avoid further executions
    }       
  }

  function createTokenUnpause() public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[29]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[29] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[29]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 29;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).unpause();
      signalTrackerID[29] = 0; // To avoid further executions
    }       
  }

  function createTokenStakingMint() public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[30]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[30] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[30]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 30;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).stakingMint();
      signalTrackerID[30] = 0; // To avoid further executions
    }       
  }

  function createTokenDAOMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[31]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[31] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[31]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 31;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.propUint = _amount;
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).daoMint(currentSignal.propUint
      );
      signalTrackerID[31] = 0; // To avoid further executions
    }       
  }

  function createTokenCommunityMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[33]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[33] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[33]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 33;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.propUint = _amount;
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).communityMint(currentSignal.propUint
      );
      signalTrackerID[33] = 0; // To avoid further executions
    }       
  }

  function createTokenDevelopmentMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[32]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[32] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[32]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 32;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.propUint = _amount;
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IToken(contracts[11]).developmentMint(currentSignal.propUint
      );
      signalTrackerID[32] = 0; // To avoid further executions
    }       
  }

  function createLordSetBaseURI(string memory _newURI) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[34]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[34] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[34]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 34;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.propString = _newURI;
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      ILord(contracts[7]).setBaseURI(currentSignal.propString
      );
      signalTrackerID[34] = 0; // To avoid further executions
    }       
  }

  function createItemSetNewTokenURI(uint256 _tokenID, string memory _newURI) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[35]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[35] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[35]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 30;
      newSignal.propUint = _tokenID;
      newSignal.propString = _newURI;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IItems(contracts[11]).setTokenURI(currentSignal.propUint, currentSignal.propString);
      signalTrackerID[35] = 0; // To avoid further executions
    }       
  }
  
  function createRoundSetPlayerRoot(uint256 _round, uint256 _level, bytes32 _root) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[36]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[36] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[36]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 36;
      newSignal.propUint = _round;
      newSignal.propUint1 = _level;
      newSignal.propBytes32 = _root;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IRound(contracts[11]).setPlayerMerkleRoot(currentSignal.propUint, currentSignal.propUint1, currentSignal.propBytes32);
      signalTrackerID[36] = 0; // To avoid further executions
    }       
  }
  
  function createGiveClanPoint(uint256 _clanID, uint256 _point, bool _isDecreasing) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal
    Signal storage currentSignal = signals[signalTrackerID[37]];

    // If current signal date passed, then start a new signal
    if (block.timestamp > currentSignal.expires) {

      signalTrackerID[37] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[37]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.signalTrackerID = 37;
      newSignal.propUint = _clanID;
      newSignal.propUint1 = _point;
      newSignal.propBool = _isDecreasing;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If there is not enough signals, count this one as well. Then continue to check it again.
    if (currentSignal.numOfSignals < (numOfExecutors / 2)){      
      // If we are in the signal time, check caller's signal status
      require(!currentSignal.isSignaled[_msgSender()], "You already signaled for this proposal");

      // If not signaled, save it and increase the number of signals
      currentSignal.isSignaled[_msgSender()] = true;
      currentSignal.numOfSignals++;
    }

    // Execute proposal if the half of the executors signaled
    if (currentSignal.numOfSignals >= (numOfExecutors / 2)){
      IClan(contracts[11]).giveClanPoint(currentSignal.propUint, currentSignal.propUint1, currentSignal.propBool);
      signalTrackerID[37] = 0; // To avoid further executions
    }       
  }

  /// @dev returns the time remeaning until the end of the singalling period
  function getSignalTiming(uint256 _signalIndex) public view returns (uint256) {
    return signals[_signalIndex].expires > block.timestamp ? signals[_signalIndex].expires - block.timestamp : 0;
  }

  
  /**
   * Updates by DAO - Update Codes
   * Executor Assignment Proposal Type Change -> Code: 1
   * Executor Propsosal -> Code: 2
   * 
   */
  function proposeFunctionsProposalTypesUpdate(uint256 _newIndex) public onlyRole(EXECUTOR_ROLE) {
    require(_newIndex != executorProposalTypeIndex, "Desired function index is already set!");
  
    string memory proposalDescription = string(abi.encodePacked(
      "In Executors contract, updating the index of executor proposal to ", 
      Strings.toHexString(_newIndex), " from ", Strings.toHexString(executorProposalTypeIndex), "."
    )); 
  
    // Create a new proposal - Call DAO contract (contracts[4])
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, executorProposalTypeIndex);
  
    // Get data to the proposal
    proposals[propID].updateCode = 1;
    proposals[propID].newUint = _newIndex;
  }
  
  function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];
  
    require(proposal.updateCode == 1 && !proposal.isExecuted, "Wrong proposal ID");
  
    // Get the proposal status from DAO contract
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));
  
    // Wait for the current one to finalize
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");
  
    // if the current one is approved, apply the update the state
    if (proposal.status == Status.Approved)
      executorProposalTypeIndex = proposal.newUint;
  
    proposal.isExecuted = true;
  }
  
  function proposeExecutorRole(address _address, bool _isAssigning) public {
    require(_address != address(0), "The executor address can not be the null address!");
    require(hasRole(EXECUTOR_ROLE, _address) != _isAssigning, "The role of the address is already same!");

    // Only addresses who hold required amount of governance token (SDAO) can call this function
    require(IDAO(contracts[4]).balanceOf(_msgSender()) >= IDAO(contracts[4]).getMinBalanceToPropose(), 
      "You don't have enough SDAO tokens to call this function!"
    );

    // Create the proposal description
    string memory proposalDescription;
    if (_isAssigning){
      proposalDescription = string(abi.encodePacked(
        "Assigning ", Strings.toHexString(_address), " address as a new executor!"
      ));
    }
    else {
      proposalDescription = string(abi.encodePacked(
        "Resigning ", Strings.toHexString(_address), " address from its executor role!"
      ));
    } 

    // Create a new proposal - DAO (contracts[4])
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, executorProposalTypeIndex);

    // Save data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].newAddress = _address;
    proposals[propID].newBool = _isAssigning;
  }

  function executeRoleProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");
  
    // Get the proposal status from DAO contract
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Check if it is finalized or not
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved){
      if (proposal.newBool){ 
        _grantRole(EXECUTOR_ROLE, proposal.newAddress);
        isExecutor[proposal.newAddress] = true;
        numOfExecutors++;
      }
      else {
        _revokeRole(EXECUTOR_ROLE, proposal.newAddress);
        isExecutor[proposal.newAddress] = false;
        numOfExecutors--;
      }
    }

    proposal.isExecuted = true;
  }

}