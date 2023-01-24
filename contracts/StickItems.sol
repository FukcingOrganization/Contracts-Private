// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

// TEST -> Control the URI things

/**
  * @notice
  * -> Executors can propose to change mintCost and stop item to be minted by SDAO approval.
  * -> Executors can update token URI without any DAO approval.
  * -> Minters have to burn certaion amount of STICK token to mint items.
  */

/**
 * @author Bora
 */
contract StickItems is ERC1155, ERC1155Burnable {
    
  struct Item {
    string itemName;
    bool isActive;
    string uri;
    uint256 mintCost;
    uint256 totalSupply;
  }

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
    If we want to change a function's proposal type, then we can simply change its type index

    Index : Associated Function
    0: Contract address update
    1: Functions Proposal Types update
    2: Mint cost update
    3: Item Activation
  */
  uint256[4] public functionsProposalTypes;

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

  mapping(uint256 => Proposal) public proposals;// Proposal ID => Proposal
  mapping(uint256 => Item) public items;

  constructor(address[13] memory _contracts) ERC1155("link/{id}.json") { // TEST
    items[0].isActive = true;       // TEST
    items[0].uri = "test0";         // TEST
    items[0].mintCost = 5 ether;    // TEST

    contracts = _contracts;  // Set the existing contracts
  }

  function uri(uint256 tokenID) public view virtual override returns (string memory) {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    return items[tokenID].uri;      
  }

  function setTokenURI(uint256 tokenID, string memory tokenURI) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    items[tokenID].uri = tokenURI;
  }

  function totalSupply(uint256 tokenID) public view virtual returns (uint256) {
    return items[tokenID].totalSupply;
  }

  function mint(uint256 id, uint256 amount, bytes memory data) public {
    require(items[id].isActive, "Stick DAO has stopped this item to be minted!!"); 

    // Burn tokens to mint
    (bool txSuccess, ) = contracts[11].call(abi.encodeWithSignature(
      "burnFrom(address,uint256)", _msgSender(), items[id].mintCost * amount
    ));
    require(txSuccess, "Burn to mint tx has failed!");

    _mint(_msgSender(), id, amount, data);
  }

  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public {
    for (uint256 i = 0; i < ids.length; i++) {
      require(items[ids[i]].isActive, "Invalid item ID!"); 

      // Burn tokens to mint
      bytes memory payload = abi.encodeWithSignature("burnFrom(address,uint256)", to, items[ids[i]].mintCost * amounts[i]);
      (bool txSuccess, ) = contracts[11].call(payload);
      require(txSuccess, "Burn to mint tx has failed!");
    }
    
    _mintBatch(to, ids, amounts, data);
  }

  /**
    * @dev reduce total supply with the before hook
    * See {ERC1155-_beforeTokenTransfer}.
    */
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

    if (from == address(0)) {
      for (uint256 i = 0; i < ids.length; ++i) {
        items[ids[i]].totalSupply += amounts[i];
      }
    }

    if (to == address(0)) {
      for (uint256 i = 0; i < ids.length; ++i) {
        uint256 id = ids[i];
        uint256 amount = amounts[i];
        uint256 supply = items[id].totalSupply;
        require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
        unchecked {items[id].totalSupply = supply - amount;}
      }
    }
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * Mist Cost -> Code: 3
   * Activation Status of Item -> Code: 4
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Items contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
      Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
    )); 

    // Create a new proposal - Call DAO contract (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[2])
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

  function proposeFunctionsProposalTypesUpdate(uint256 _functionIndex, uint256 _newIndex) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newIndex != functionsProposalTypes[_functionIndex], "Desired function index is already set!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Items contract, updating proposal types of index ", Strings.toHexString(_functionIndex), " to ", 
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

  function proposeMintCostUpdate(uint256 _itemID, uint256 _newCost) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Items contract, updating mint cost of item ID: ", Strings.toHexString(_itemID), " to ", 
      Strings.toHexString(_newCost), " from ", Strings.toHexString(items[_itemID].mintCost), "."
    )); 

    // Create a new proposal - DAO (contracts[4])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[2])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 3;
    proposals[propID].index = _itemID;
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
      items[proposal.index].mintCost = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeItemActivationUpdate(uint256 _itemID, bool _activationStatus) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(items[_itemID].isActive != _activationStatus, "The activation status is already same!");

    string memory proposalDescription;
    if (_activationStatus){
      proposalDescription = string(abi.encodePacked(
        "In Items contract, updating activation status of item ID: ", 
        Strings.toHexString(_itemID), " to ", " TRUE from FALSE."
      )); 
    }
    else {
      proposalDescription = string(abi.encodePacked(
        "In Items contract, updating activation status of item ID: ", 
        Strings.toHexString(_itemID), " to ", " FALSE from TRUE."
      )); 
    }

    // Create a new proposal - DAO (contracts[4]) - Less Important Proposal (proposalTypes[0])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[3])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 4;
    proposals[propID].index = _itemID;
    proposals[propID].newBool = _activationStatus;
  }

  function executeItemActivationProposal(uint256 _proposalID) public {
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
      items[proposal.index].isActive = proposal.newBool;

    proposal.isExecuted = true;
  }
}