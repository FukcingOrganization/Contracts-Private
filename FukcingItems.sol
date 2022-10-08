// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

/**
  * -> Based on ERC-1155
  * -> Set uri, mintCost of items, pause item function by DAO approval
  * -> Update: DAO and Executer add, UpdatePropType, mintCosts[]
  */

/**
  * Info:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */

/*
 * @author Bora
 */



contract FukcingItems is ERC1155, ERC1155Burnable {
    
  struct Item {
    string itemName;
    bool isActive;
    string uri;
    uint256 mintCost;
    uint256 totalSupply;
  }

  mapping(uint256 => Item) public items;

  address public fukcingExecutors;
  address public fukcingDAO;
  address public fukcingToken;

  constructor() ERC1155("test-uri-link-here") {
    items[0].isActive = true;       // TEST
    items[0].uri = "test0";         // TEST
    items[0].mintCost = 5 ether;    // TEST

    fukcingToken = 0x93f8dddd876c7dBE3323723500e83E202A7C96CC; // TEST
  }

  function uri(uint256 tokenID) public view virtual override returns (string memory) {
    return items[tokenID].uri;      
  }

  function setTokenURI(uint256 tokenID, string memory tokenURI) public {
    items[tokenID].uri = tokenURI;
  }

  function totalSupply(uint256 tokenID) public view virtual returns (uint256) {
    return items[tokenID].totalSupply;
  }

  function mint(address account, uint256 id, uint256 amount, bytes memory data) public {
    require(items[id].isActive, "Invalid item ID!"); 

    // Burn tokens to mint
    (bool txSuccess, ) = fukcingToken.call(abi.encodeWithSignature("burnFrom(address,uint256)", account, items[id].mintCost * amount));
    require(txSuccess, "Burn to mint tx has failed!");

    _mint(account, id, amount, data);
  }

  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public {
    for (uint256 i = 0; i < ids.length; i++) {
      require(items[ids[i]].isActive, "Invalid item ID!"); 

      // Burn tokens to mint
      bytes memory payload = abi.encodeWithSignature("burnFrom(address,uint256)", to, items[ids[i]].mintCost * amounts[i]);
      (bool txSuccess, ) = fukcingToken.call(payload);
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
}