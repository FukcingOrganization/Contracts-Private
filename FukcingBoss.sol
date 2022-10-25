// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
  * @notice
  * -> You can mint, select, and fukc a boss!
  *
  * -> Boss NFTs can't be transferred therefore can't be sold!
  * -> The minter can only change metadata by setting token URI.
  * -> Minters have to burn certaion amount of FUKC token to mint a boss.
  *
  * -> Executers can propose to update contract addresses, proposal types, and the mint cost.
  */

/**
  * @author Bora
  */
contract FukcingBoss is ERC721, ERC721URIStorage, ERC721Burnable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

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

  mapping(uint256 => Proposal) public proposals;// Proposal ID => Proposal
  mapping(uint256 => uint256) public numOfFukc; // token ID => How many times this boss get fukced

  uint256 public totalSupply;
  uint256 public mintCost;

  constructor() ERC721("FukcingBoss", "FBOSS") {
    mintCost = 66666 ether; // TEST -> Change it with final value
  }
    
  /**
   *  @dev Making token non-transferable by overriding all the transfer functions
   */
  function approve(address spender, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function setApprovalForAll(address operator, bool approved) public virtual override {
    revert("This is a non-transferable token!");
  }
    
  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
    revert("This is a non-transferable token!");
  }
  
  // The following 2 functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    totalSupply--;
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
    return super.tokenURI(tokenId);
  }

  function safeMint(address to, string memory uri) public {
    // Burn the mist cost to mint
    ERC20Burnable(contracts[11]).burnFrom(_msgSender(), mintCost);

    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    totalSupply++;
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
    require(ownerOf(tokenId) == _msgSender(), "Only the owner can change the URI!");
    _setTokenURI(tokenId, _tokenURI);
  }

  function bossFukced(uint256 _tokenID) public {
    require(_msgSender() == contracts[9], "Only the Fukcing Seance contract can write!");

    numOfFukc[_tokenID]++;
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * Mist Cost -> Code: 3
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Boss contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
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
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Boss contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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

  function proposeMintCostUpdate(uint256 _newCost) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Boss contract, updating mint cost of Boss to ", Strings.toHexString(_newCost), 
      " from ", Strings.toHexString(mintCost), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 3;
    proposals[propID].newUint = _newCost;
  }

  function executeMintCostProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 3 && !proposal.isExecuted, "Wrong proposal ID");

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
      mintCost = proposal.newUint;

    proposal.isExecuted = true;
  }
}
