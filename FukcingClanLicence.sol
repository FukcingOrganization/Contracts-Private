// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
  * -> Update: DAO and Executer add, UpdatePropType, mintCosts[]
  */

/**
  * @notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */

/**
  * @author Bora
  */

contract FukcingClanLicence is ERC1155, ERC1155Burnable {

  mapping(uint256 => uint256) public numOfActiveLicence; // LordID => current number of Licence
  mapping(uint256 => string) public customURI; // LordID => current number of Licence

  address public fukcingExecutors;
  address public fukcingDAO;
  address public fukcingToken;
  address public fukcingLord;

  uint256 public mintCost;

  constructor() ERC1155("link/{id}.json") { // TEST 
  }

  // @dev returns the valid URI of the licence
  function uri(uint256 _lordID) public view virtual override returns (string memory){
    return (bytes(customURI[_lordID]).length) > 0 ? customURI[_lordID] : super.uri(_lordID);
  }

  function burn(
      address account,
      uint256 id,
      uint256 value
  ) public virtual override {
    // Substract the burn amount from the number of active licence of the lord    
    numOfActiveLicence[id] -= value;

    super.burn(account, id, value);
  }

  function setCustomURI(uint256 _lordID, string memory _customURI) public {
    require(_msgSender() == fukcingLord, "Only the Fukcing Lords can call this fukcing function! Now, back off you prick!");
    customURI[_lordID] = _customURI;
  }

  function mintLicence(address _lordAddress, uint256 _lordID, uint256 _amount, bytes memory _data) public {
    require(_msgSender() == fukcingLord, "Only the Fukcing Lords can call this fukcing function! Now, back off you prick!");
    require(numOfActiveLicence[_lordID] + _amount <= 3, "Maximum number of active licence exceeds!");

    // Burn tokens to mint
    ERC20Burnable(fukcingToken).burnFrom(_lordAddress, _amount * mintCost);

    numOfActiveLicence[_lordID] += _amount;       // Add the new licences
    _mint(_lordAddress, _lordID, _amount, _data); // Mint
  }
}