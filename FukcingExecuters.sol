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

  mapping(uint256 => Proposal) public proposals;          // proposalID => Proposal
  mapping(address => bool) public isExecutor;  // The executors

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


  function updateContractAddress(
    uint256 contractIndex,  // Destination Contract address
    uint256 subjectIndex,   // The address that we want to update in the destination contract. Same index as contracts
    address newAddress,     // New address
    bool isNewProposal      
  ) public onlyRole(EXECUTER_ROLE) {
    (bool txSuccess, ) = contracts[contractIndex].call(abi.encodeWithSignature(
      "updateContractAddress(uint256,address,bool)", subjectIndex, newAddress, isNewProposal
    ));
    require(txSuccess, "Transaction failed to execute update function!");   
  }

  // 

  // Proposals to update the state of the executor contract

  function setExecuter(address _address, bool _setAsExecuter, bool isNewProposal) public {
    // require executor status is not already set
    if (_setAsExecuter)
      require(hasRole(EXECUTER_ROLE, _address) == false, "The address is already an executor!");
    else
      require(hasRole(EXECUTER_ROLE, _address) == true, "The address is already NOT an executor!");


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
        

    // if PID[4] is 0, make a new proposal
    if (proposalIdTracker[4] == 0 && isNewProposal) { // Which is default
      require(_address != address(0), "The executor address can not be the null address!");
            
      string memory proposalDescription;
      if (_setAsExecuter){
        proposalDescription = string(abi.encodePacked(
          "Assigning executor status of ", Strings.toHexString(_address), " address as TRUE"
        ));
      }
      else {
        proposalDescription = string(abi.encodePacked(
          "Assigning executor status of ", Strings.toHexString(_address), " address as FALSE"
        ));
      } 

      // Create a new proposal
      (bool txSuccess2, bytes memory returnData2) = contracts[4].call(
        abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalType)
      );
      require(txSuccess2, "Transaction failed to make new proposal!");

      // Save the ID to proposalIdTracker[4]
      (proposalIdTracker[4]) = abi.decode(returnData2, (uint256));

      // Get new state update by proposal ID we get from newProposal
      proposals[proposalIdTracker[4]].newAddress = _address;
      proposals[proposalIdTracker[4]].newBool = _setAsExecuter;

      return; // Finish the function
    }

    // If there is already a proposal, Get its result from DAO
    (bool txSuccess3, bytes memory returnData3) = contracts[4].call(
      abi.encodeWithSignature("proposalResult(uint256)", proposalIdTracker[4])
    );
    require(txSuccess3, "Transaction failed to make new proposal!");

    // Save it here
    Proposal storage proposal = proposals[proposalIdTracker[4]];
    (uint256 statusNum) = abi.decode(returnData3, (uint256));
    proposal.status = Status(statusNum);

    // Wait for the current one to finalize
    string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
      " Wait for the DAO decision on the proposal! The proposal ID = ", Strings.toString(proposalIdTracker[4]), "."
    )); 
    require(uint256(proposal.status) > 1, errorText);

    // if the current one is approved, take action according to newBool which is _setAsExecuter
    if (proposal.status == Status.Approved){
      if (proposal.newBool == true)
        _grantRole(EXECUTER_ROLE, proposal.newAddress);
      else
        _revokeRole(EXECUTER_ROLE, proposal.newAddress);
    }

    proposalIdTracker[4] = 0;   // reset proposal tracker
  }

}