// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @notice
 * -> Renting contract using STICK token as a medium of exchange.
 * -> Lord owner can list and delist its NFT for a specific length and fee.
 * -> Everyone can rent a listed lord NFT except the owner of the lord.
 */


interface IDAO {
  function newProposal(string memory _description, uint256 _proposalType) external returns(uint256);
  function proposalResult(uint256 _proposalID) external returns(uint256);
}

interface ILord {
  function setUser(uint256 tokenId, address user, uint256 expires) external;
}

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

  mapping(uint256 => Proposal) public proposals;  // Proposal ID => Proposal
  mapping(uint256 => Listing) public listings;    // Lord ID => Listing

  constructor (address[13] memory _contracts) {
    contracts = _contracts;  // Set the existing contracts
  }

  function DEBUG_setContract(address _contractAddress, uint256 _index) public {
    contracts[_index] = _contractAddress;
  }

  function DEBUG_setContracts(address[13] memory _contracts) public {
    contracts = _contracts;
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
    ILord(contracts[7]).setUser(listing.lordID, _msgSender(), (block.timestamp + listing.length));
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
    require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

    // if the current one is approved, apply the update the state
    if (proposal.status == Status.Approved)
      proposalTypeIndex = proposal.newUint;

    proposal.isExecuted = true;
  }
}