// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./ERC721.sol";
import "./Context.sol";
import "./Strings.sol";

/**
 * @notice
 * -> Renting contract using STICK token as a medium of exchange.
 * -> Lord owner can list and delist its NFT for a specific lenght and fee.
 * -> Everyone can rent a listed lord NFT except the owner of the lord.
 */

/**
 * @author Bora
 */
contract StickRent is Context {

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

  struct Listing {
    bool isListed;
    uint256 lordID;
    address ownerAddress;
    uint256 fee;
    uint256 length;
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

  mapping(uint256 => Proposal) public proposals;  // Proposal ID => Proposal
  mapping(uint256 => Listing) public listings;    // Lord ID => Listing

  constructor (address _lordContract, address _tokenContract) {
    contracts[7] = _lordContract;
    contracts[11] = _tokenContract;
  }

  function list(uint256 _lordID, uint256 _rentFee, uint256 _length) public {
    address owner = ERC721(contracts[7]).ownerOf(_lordID);
    require(_msgSender() == owner, "You can't list a lord NFT that you don't have!");

    Listing storage listing = listings[_lordID];

    listing.isListed = true;
    listing.lordID = _lordID;
    listing.ownerAddress = owner;
    listing.fee = _rentFee;
    listing.length = _length;
  }

  function delist(uint256 _lordID) public {
    // Get the owner from the lord contract (contracts[7])
    address owner = ERC721(contracts[7]).ownerOf(_lordID);
    require(_msgSender() == owner, "You can't delist a lord NFT that you don't have!");

    Listing storage listing = listings[_lordID];

    listing.isListed = false;
    listing.fee = 0;
    listing.length = 0;    
  }

  function rent(uint256 _lordID) public {
    // Get the listing
    Listing storage listing = listings[_lordID];
    require(listing.isListed, "This lord isn't listed. Sorry!");
    require(_msgSender() != listing.ownerAddress, "Dude! WTF? You can't rent your own shit!");

    // Transfer the fee from caler to owner
    IERC20(contracts[11]).transferFrom(_msgSender(), listing.ownerAddress, listing.fee);

    // Rent the NFT
    bytes memory payload = abi.encodeWithSignature("setUser(uint256,address,uint256)", listing.lordID, _msgSender(), (block.timestamp + listing.length));
    (bool txSuccess, ) = contracts[7].call(payload);
    require(txSuccess, "Transaction has fail to set rent from the Lord contract!");
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
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Rent contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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
}