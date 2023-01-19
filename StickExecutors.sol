// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Context.sol";
import "./AccessControl.sol";
import "./Counters.sol";

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
  function proposeClanPointAdjustment(uint256 _roundNumber, uint256 _clanID, uint256 _pointToChange, bool _isDecreasing) external;
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
  function proposeMinBalanceToPropUpdate(uint256 _newAmount) external;
  function proposeMinBalanceToPropClanPointUpdate(uint256 _newAmount) external;
  function proposeClanPointChange(uint256 _clanID, uint256 _pointsToChange, bool _isDecreasing) external;
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
}

interface IItems {
  function proposeMintCostUpdate(uint256 _itemID, uint256 _newCost) external;
  function proposeItemActivationUpdate(uint256 _itemID, bool _activationStatus) external;
}

interface ILord {
  function proposeBaseTaxRateUpdate(uint256 _newBaseTaxRate) external;
  function proposeTaxChangeRateUpdate(uint256 _newTaxChangeRate) external;
  function proposeRebellionLenghtUpdate(uint256 _newRebellionLenght) external;
  function proposeSignalLenghtUpdate(uint256 _newSignalLenght) external;
  function proposeVictoryRateUpdate(uint256 _newVictoryRate) external;
  function proposeWarCasualtyRateUpdate(uint256 _newWarCasualtyRate) external;
}

interface IToken {
  function proposeMintPerSecondUpdate(uint256 _mintIndex, uint256 _newMintPerSecond) external;
  function proposeToIncreaseMaxSupply(uint256 _newMaxSupply) external;
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
    uint256 numOfSignals;
    mapping(address => bool) isSignaled;

    uint256 contractIndex;
    uint256 subjectIndex;
    address propAddrees;
    uint256 propUint;
  }

  Counters.Counter private signalCounter;

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

  /** 
    If we want to change a function's proposal type, then we can simply change its type index

    Index : Associated Function
    0: Contract address update
    1: Functions Proposal Types update
    2: Executor Role
  */
  uint256[3] public functionsProposalTypes;

  uint256 public numOfExecutors;
  uint256[] public signalTrackerID;
  uint256 public signalTime;

  constructor() {
    // Grant the deployer as an executor
    _grantRole(EXECUTOR_ROLE, _msgSender());
    numOfExecutors++;  

    // At least half of the executor should signal within (initially) 1 day to execute a new proposal 
    signalTime = 1 days;        
    signalCounter.increment();  // Start the counter from 1
  }

  /**
   * Signal Tracker IDs
   *
   * Contract Address Update: 1
   * Proposal Type Update: 2      MISSING - ADD IT
   * Lord mint cost update: 3
   */
  function createContractAddressUpdateProposal(
    uint256 _contractIndex,  // Destination Contract address
    uint256 _subjectIndex,   // The address that we want to update in the destination contract. Same index as contracts
    address _newAddress      // New address
  ) public onlyRole(EXECUTOR_ROLE) {
    // Get the current signal ID for this proposal function
    uint256 sID = signalTrackerID[1];

    // If current signal date passed, then start a new signal
    if (block.timestamp > signals[sID].expires) {
      require(_newAddress != address(0), "You can't set the address to null!");

      signalTrackerID[1] = signalCounter.current();           // Save the current signal ID to the tracker
      Signal storage newSignal = signals[signalTrackerID[1]]; // Get the signal
      signalCounter.increment();  // Increment the counter for other signals

      // Save data
      newSignal.expires = block.timestamp + signalTime;
      newSignal.contractIndex = _contractIndex;
      newSignal.subjectIndex = _subjectIndex;
      newSignal.propAddrees = _newAddress;

      newSignal.isSignaled[_msgSender()] = true;  // Save the executor address as signaled
      newSignal.numOfSignals++;
      return; // finish the function
    }   

    // If we are in the signal time, get the signal and check caller's signal status
    Signal storage signal = signals[signalTrackerID[1]];
    require(!signal.isSignaled[_msgSender()], "You already signaled for this proposal");

    // If not signaled, save it and increase the number of signals
    signal.isSignaled[_msgSender()] = true;
    signal.numOfSignals++;

    // Execute proposal if the half of the executors signaled
    if (signal.numOfSignals >= (numOfExecutors / 2)){
      IBaseUpdate(contracts[signal.contractIndex]).proposeContractAddressUpdate(signal.subjectIndex, signal.propAddrees);
      signal.expires = 0; // To avoid further executions
    }       
  }

  
  /**
   * Updates by DAO - Update Codes
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * Executor Propsosal -> Code: 3
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public onlyRole(EXECUTOR_ROLE) {
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Executors, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
      Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[0])
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

  function proposeFunctionsProposalTypesUpdate(uint256 _functionIndex, uint256 _newIndex) public onlyRole(EXECUTOR_ROLE) {
    require(_newIndex != functionsProposalTypes[_functionIndex], "Desired function index is already set!");
  
    string memory proposalDescription = string(abi.encodePacked(
      "In Executors contract, updating proposal types of index ", Strings.toHexString(_functionIndex), " to ", 
      Strings.toHexString(_newIndex), " from ", Strings.toHexString(functionsProposalTypes[_functionIndex]), "."
    )); 
  
    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");
  
    // Save the ID
    (uint256 propID) = abi.decode(returnData, (uint256));
  
    // Get data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].index = _functionIndex;
    proposals[propID].newUint = _newIndex;
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
      functionsProposalTypes[proposal.index] = proposal.newUint;
  
    proposal.isExecuted = true;
  }
  
  function proposeExecutorRole(address _address, bool _setAsExecutor) public {
    require(_address != address(0), "The executor address can not be the null address!");
    require(hasRole(EXECUTOR_ROLE, _address) != _setAsExecutor, "The role of the address is already same!");

    /// *************** Check Caller's Eligibility to Propose *************** ///

    // Only addresses who hold required amount of governance token (SDAO) can call this function
    // Get required balance to propose
    (bool txSuccess0, bytes memory returnData0) = 
      contracts[4].call(abi.encodeWithSignature("getMinBalanceToPropose()")
    );
    require(txSuccess0, "Transaction failed to get required balance to propose from DAO!");
    (uint256 requiredBalance) = abi.decode(returnData0, (uint256));

    // Get caller's balance
    (bool txSuccess1, bytes memory returnData1) = 
      contracts[4].call(abi.encodeWithSignature("balanceOf(address)", _msgSender())
    );
    require(txSuccess1, "Transaction failed to get SDAO token balance of the caller!");
    (uint256 callerBalance) = abi.decode(returnData1, (uint256));

    require(callerBalance >= requiredBalance, "You don't have enough SDAO tokens to call this function!");

        
    /// ************************** Create Proposal ************************** ///

            
    string memory proposalDescription;
    if (_setAsExecutor){
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
    (bool txSuccess2, bytes memory returnData2) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[2])
    );
    require(txSuccess2, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData2, (uint256));

    // Save data to the proposal
    proposals[propID].updateCode = 3;
    proposals[propID].newAddress = _address;
    proposals[propID].newBool = _setAsExecutor;
  }

  function executeRoleProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 3 && !proposal.isExecuted, "Wrong proposal ID");

    // Get the proposal result from DAO
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the result here
    (uint256 statusNum) = abi.decode(returnData, (uint256));
    proposal.status = Status(statusNum);

    // Check if it is finalized or not
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved){
      if (proposal.newBool == true){ 
        _grantRole(EXECUTOR_ROLE, proposal.newAddress);
        numOfExecutors++;
      }
      else {
        _revokeRole(EXECUTOR_ROLE, proposal.newAddress);
        numOfExecutors--;
      }
    }

    proposal.isExecuted = true;
  }

}