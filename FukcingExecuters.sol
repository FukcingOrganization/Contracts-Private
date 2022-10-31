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
 * -> Executers executes update proposals to maintain the sustainablity and balance in WeFukc.
 * -> At least half of the executers should signal to propose a new proposal within the signal time
 * -> FDAO can hire or fire executers.
 */

/**
 * @author Bora
 */
contract FukcingExecuters is Context, AccessControl {
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

  bytes32 public constant EXECUTER_ROLE = keccak256("EXECUTER_ROLE");

  /** 
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

  /**
   * proposalTypes's Indexes with corresponding meaning
   *  
   * Index 0: Less important proposals
   * Index 1: Moderately important proposals
   * Index 2: Highly important proposals
   * Index 3: MAX SUPPLY CHANGE PROPOSAL
   */
  uint256[4] public proposalTypes;

  uint256 public numOfExecuters;
  uint256[] public signalTrackerID;
  uint256 public signalTime;

  constructor() {
    // Grant the deployer as an executer
    _grantRole(EXECUTER_ROLE, _msgSender());
    numOfExecuters++;  

    // At least half of the executer should signal within (initially) 1 day to execute a new proposal 
    signalTime = 1 days;        
    signalCounter.increment();  // Start the counter from 1
  }

  /**
   * Signal Tracker IDs
   *
   * Contract Address Update: 1
   * Proposal Type Update: 2
   */
  function createContractAddressUpdateProposal(
    uint256 _contractIndex,  // Destination Contract address
    uint256 _subjectIndex,   // The address that we want to update in the destination contract. Same index as contracts
    address _newAddress     // New address
  ) public onlyRole(EXECUTER_ROLE) {
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

      newSignal.numOfSignals++;
      newSignal.isSignaled[_msgSender()] = true;  // Save the executer address as signaled
      return; // finish the function
    }   

    // If we are in the signal time, get the signal and check caller's signal status
    Signal storage signal = signals[signalTrackerID[1]];
    require(!signal.isSignaled[_msgSender()], "You already signaled for this proposal");

    // If not signaled, save it and increase the number of signals
    signal.isSignaled[_msgSender()] = true;
    signal.numOfSignals++;

    // Execute proposal if the half of the executers signaled
    if (signal.numOfSignals >= (numOfExecuters / 2)){
      (bool txSuccess, ) = contracts[_contractIndex].call(abi.encodeWithSignature(
        "proposeContractAddressUpdate(uint256,address)", _subjectIndex, _newAddress
      ));
      require(txSuccess, "Transaction failed to execute update function!");
    }       
  }

  
  /**
   * Updates by DAO - Update Codes
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * Executer Propsosal -> Code: 3
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public onlyRole(EXECUTER_ROLE) {
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Executers, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
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

  function proposeProposalTypesUpdate(uint256 _proposalIndex, uint256 _newType) public onlyRole(EXECUTER_ROLE) {
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");
  
    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Executers contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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
  
  function proposeExecuterRole(address _address, bool _setAsExecuter) public {
    require(_address != address(0), "The executor address can not be the null address!");
    require(hasRole(EXECUTER_ROLE, _address) != _setAsExecuter, "The role of the address is already same!");

    /// *************** Check Caller's Eligibility to Propose *************** ///

    // Only addresses who hold required amount of governance token (FDAO) can call this function
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
    require(txSuccess1, "Transaction failed to get FDAO token balance of the caller!");
    (uint256 callerBalance) = abi.decode(returnData1, (uint256));

    require(callerBalance >= requiredBalance, "You don't have enough FDAO tokens to call this function!");

        
    /// ************************** Create Proposal ************************** ///

            
    string memory proposalDescription;
    if (_setAsExecuter){
      proposalDescription = string(abi.encodePacked(
        "Assigning ", Strings.toHexString(_address), " address as a new executer!"
      ));
    }
    else {
      proposalDescription = string(abi.encodePacked(
        "Resigning ", Strings.toHexString(_address), " address from its executer role!"
      ));
    } 

    // Create a new proposal - DAO (contracts[4]) - Highly Important Proposal (proposalTypes[2])
    (bool txSuccess2, bytes memory returnData2) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
    );
    require(txSuccess2, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData2, (uint256));

    // Save data to the proposal
    proposals[propID].updateCode = 3;
    proposals[propID].newAddress = _address;
    proposals[propID].newBool = _setAsExecuter;
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
        _grantRole(EXECUTER_ROLE, proposal.newAddress);
        numOfExecuters++;
      }
      else {
        _revokeRole(EXECUTER_ROLE, proposal.newAddress);
        numOfExecuters--;
      }
    }

    proposal.isExecuted = true;
  }

}