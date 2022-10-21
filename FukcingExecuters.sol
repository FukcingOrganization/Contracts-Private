// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
  * -> Add contract addresses
  * -> Fire and hire executors with FDAO approval with 80% approval rate
  * -> Update: all addresses, proposal type, 
  */

/*
 * @author Bora
 */
 
/**
  * notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */

contract FukcingExecuters is Context, AccessControl {

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

  mapping(uint256 => Proposal) public proposals;  // proposalID => Proposal
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
  address[] public executors;   // List of executors
  uint256 public proposalType;

  constructor() {
    executors.push(_msgSender());
    isExecutor[_msgSender()] = true;

    proposalType = 3;           // TEST -> Change it with the final value
  }


  function createContractAddressUpdateProposal(
    uint256 contractIndex,  // Destination Contract address
    uint256 subjectIndex,   // The address that we want to update in the destination contract. Same index as contracts
    address newAddress     // New address
  ) public onlyRole(EXECUTER_ROLE) {
    (bool txSuccess, ) = contracts[contractIndex].call(abi.encodeWithSignature(
      "proposeContractAddressUpdate(uint256,address,bool)", subjectIndex, newAddress
    ));
    require(txSuccess, "Transaction failed to execute update function!");   
  }

  
  /**
   * Updates by DAO - Update Codes
   * Executer Propsosal -> Code: 1
   * xxxxx -> Code: 2
   * yyyyy -> Code: 3
   * zzzzz -> Code: 4
   * 
  **/

  // Proposals to update the state of the executor contract

  function proposeExecuterRole(address _address, bool _setAsExecuter) public {
    require(_address != address(0), "The executor address can not be the null address!");

    // require executor status is not already set
    if (_setAsExecuter)
      require(hasRole(EXECUTER_ROLE, _address) == false, "The address is already an executor!");
    else
      require(hasRole(EXECUTER_ROLE, _address) == true, "The address is already NOT an executor!");


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

    // Create a new proposal
    (bool txSuccess2, bytes memory returnData2) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalType)
    );
    require(txSuccess2, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData2, (uint256));

    // Save data to the proposal
    proposals[propID].updateCode = 1;
    proposals[propID].newAddress = _address;
    proposals[propID].newBool = _setAsExecuter;
  }

  function executeRoleProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 1 || proposal.isExecuted == false, "Wrong proposal ID");

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
      if (proposal.newBool == true)
        _grantRole(EXECUTER_ROLE, proposal.newAddress);
      else
        _revokeRole(EXECUTER_ROLE, proposal.newAddress);
    }

    proposal.isExecuted = true;
  }

}