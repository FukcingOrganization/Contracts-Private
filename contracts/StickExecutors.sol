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

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////


  
  function createBossMintCostUpdateProposal(uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    IBoss(contracts[0]).proposeMintCostUpdate(_newCost);
  }
  
  function createClanMaxPointToChangeUpdateProposal(uint256 _newMaxPoint) public onlyRole(EXECUTOR_ROLE) {
    IClan(contracts[1]).proposeMaxPointToChangeUpdate(_newMaxPoint);    
  }
  
  function createClanCooldownTimeUpdateProposal(uint256 _newCoolDownTime) public onlyRole(EXECUTOR_ROLE) {
    IClan(contracts[1]).proposeCooldownTimeUpdate(_newCoolDownTime);
  }
  
  function createClanLicenseMintCostUpdateProposal(uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    IClanLicense(contracts[2]).proposeMintCostUpdate(_newCost);
  }
  
  function createCommunityRewardProposal(
    address[] memory _receivers,
    uint256[] memory _rewards
  ) public onlyRole(EXECUTOR_ROLE) {
    ICommunity(contracts[3]).proposeReward(_receivers, _rewards);
  }
  
  function createCommunityMerkleRewardProposal(
    bytes32[] memory _roots, 
    uint256[] memory _rewards,
    uint256 _totalReward
  ) public onlyRole(EXECUTOR_ROLE) {
    ICommunity(contracts[3]).proposeMerkleReward(_roots, _rewards, _totalReward);
  }
  
  function createCommunityHighRewarLimitSetProposal(uint256 _newLimit) public onlyRole(EXECUTOR_ROLE) {
    ICommunity(contracts[3]).proposeHighRewarLimitSet(_newLimit);
  }
  
  function createCommunityExtremeRewardLimitSetProposal(uint256 _newLimit) public onlyRole(EXECUTOR_ROLE) {
    ICommunity(contracts[3]).proposeHighRewarLimitSet(_newLimit);   
  }
  
  function createDAOMinBalanceToPropUpdateProposal(uint256 _newAmount) public onlyRole(EXECUTOR_ROLE) {
    IDAO(contracts[4]).proposeMinBalanceToPropUpdate(_newAmount);   
  }

  function createDAONewTokenSpendingProposal(
    address _tokenContractAddress, 
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending
  ) public onlyRole(EXECUTOR_ROLE) {
    IDAO(contracts[4]).proposeNewTokenSpending(_tokenContractAddress, _merkleRoots, _allowances, _totalSpending);   
  }

  function createDAONewCoinSpendingProposal(
    bytes32[] memory _merkleRoots, 
    uint256[] memory _allowances, 
    uint256 _totalSpending
  ) public onlyRole(EXECUTOR_ROLE) {
    IDAO(contracts[4]).proposeNewCoinSpending(_merkleRoots, _allowances, _totalSpending);  
  }

  
  function createDAONewProposalTypeProposal(
    uint256 _length, 
    uint256 _requiredApprovalRate, 
    uint256 _requiredTokenAmount, 
    uint256 _requiredParticipantAmount
  ) public onlyRole(EXECUTOR_ROLE) {
      IDAO(contracts[4]).proposeNewProposalType(_length, _requiredApprovalRate, _requiredTokenAmount, _requiredParticipantAmount);
  }
  
  function createClanMinBalanceToPropClanPointUpdateProposal(uint256 _newAmount) public onlyRole(EXECUTOR_ROLE) {
    IClan(contracts[1]).proposeMinBalanceToPropClanPointUpdate(_newAmount);   
  }
  
  function createItemsMintCostUpdateProposal(uint256 _itemID, uint256 _newCost) public onlyRole(EXECUTOR_ROLE) {
    IItems(contracts[6]).proposeMintCostUpdate(_itemID, _newCost);
  }
  
  function createItemActivationUpdateProposal(uint256 _itemID, bool _activationStatus) public onlyRole(EXECUTOR_ROLE) {
    IItems(contracts[6]).proposeItemActivationUpdate(_itemID, _activationStatus);
  }
  
  function createLordSignalLenghtUpdateProposal(uint256 _newSignalLenght) public onlyRole(EXECUTOR_ROLE) {
    ILord(contracts[7]).proposeBaseTaxRateUpdate(_newSignalLenght);
  }
  
  function createWarLordCasualtyRateUpdateProposal(uint256 _newWarCasualtyRate) public onlyRole(EXECUTOR_ROLE) {
    ILord(contracts[7]).proposeBaseTaxRateUpdate(_newWarCasualtyRate);
  }

  function createTokenSnapshot() public onlyRole(EXECUTOR_ROLE) {
    IToken(contracts[11]).snapshot();
  }

  function createTokenStakingMint() public onlyRole(EXECUTOR_ROLE) {
    IToken(contracts[11]).stakingMint();
  }

  function createTokenDAOMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    IToken(contracts[11]).daoMint(_amount);   
  }

  function createTokenCommunityMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    IToken(contracts[11]).communityMint(_amount);
  }

  function createTokenDevelopmentMint(uint256 _amount) public onlyRole(EXECUTOR_ROLE) {
    IToken(contracts[11]).developmentMint(_amount);
  }

  function createLordSetBaseURI(string memory _newURI) public onlyRole(EXECUTOR_ROLE) {
    ILord(contracts[7]).setBaseURI(_newURI);
  }

  function createItemSetNewTokenURI(uint256 _tokenID, string memory _newURI) public onlyRole(EXECUTOR_ROLE) {
    IItems(contracts[11]).setTokenURI(_tokenID, _newURI);
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
      if (proposal.newBool == true){ 
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