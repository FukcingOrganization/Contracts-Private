// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
/**
  * -> Rebellion Mechanism
  * -> Make it rentable
  * -> Update: DAO and Executer add, UpdatePropType, baseTax, taxchangeRate,
  */

/*
 * @author Bora
 */

/**
  * notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  * -> Mint clanLicence (max 3 licence can exist in the same time), can set custom URI for it licences
  * -> Tax rate : base + (taxRateChange * num of glories)
  */

contract FukcingLord is ERC721, ERC721Burnable {  
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  address public fukcingExecutors;
  address public fukcingDAO;
  address public fukcingToken;
  address public fukcingClan;
  address public fukcingClanLicence;

  mapping(uint256 => uint256) public numberOfClans; // that the lord has | Lord ID => number of clans
  mapping(uint256 => uint256[]) public clansOf; // that the lord has | Lord ID => Clan IDs in array []
  // Lord ID => number of licencese in cirulation (not used therefore not burnt)
  mapping(uint256 => uint256) public numberOfActiveLicences; 
  mapping(uint256 => uint256) public numberOfGlories;

  uint256 public totalSupply;
  uint256 public maxSupply;
  uint256 public mintCost;
  uint256 public baseTaxRate;
  uint256 public taxChangeRate;

  constructor() ERC721("FukcingLord", "FLORD") {
    _tokenIdCounter.increment();
    maxSupply = 666;
    mintCost = 60 ether;  // TEST -> Change it with the final value
    baseTaxRate = 10;     // TEST -> Change it with the final value
    taxChangeRate = 5;    // TEST -> Change it with the final value
  }

  function _burn(uint256 tokenId) internal override {
    totalSupply--;
    super._burn(tokenId);
  }

  function safeMint(address to) public {
    uint256 tokenId = _tokenIdCounter.current();

    require(tokenId < maxSupply, "Sorry mate, there can ever be only 666 Fukcing Lords, and they are all out!");
    ERC20Burnable(fukcingToken).burnFrom(_msgSender(), mintCost);
    
    _tokenIdCounter.increment();
    totalSupply++;
    _safeMint(to, tokenId);
  }

  function mintClanLicence(uint256 _lordID, uint256 _amount, bytes memory _data) public {
    require(ownerOf(_lordID) == _msgSender(), "Who are you fooling? You are not the Lord that you claim to be!");
    require(numberOfActiveLicences[_lordID] + _amount <= 3, "Maximum number of active licence exceeds!");
    
    bytes memory payload = abi.encodeWithSignature("mintLicence(address,uint256,uint256,bytes)", _msgSender(), _lordID, _amount, _data);
    (bool txSuccess, ) = address(fukcingClanLicence).call(payload);
    require(txSuccess, "Transaction has fail to mint new licence from the Fukcing Licence contract!");
  }

  function setCustomLicenceURI(uint256 _lordID, string memory _newURI) public {
    require(ownerOf(_lordID) == _msgSender(), "Who are you fooling? You are not the Lord that you claim to be!");

    bytes memory payload = abi.encodeWithSignature("setCustomURI(uint256,string)", _lordID, _newURI);
    (bool txSuccess, ) = address(fukcingClanLicence).call(payload);
    require(txSuccess, "Transaction has fail to set a new URI for the Fukcing Licence!");
  }

  function clanRegistration(uint256 _lordID, uint256 _clanID) public {
    require(_msgSender() == fukcingClan, "Only the Fukcing Clan contract can call this fukcing function! Now, back off you domass!");

    clansOf[_lordID].push(_clanID);     // Keep the record of the clan ID
    numberOfActiveLicences[_lordID]--;  // Reduce the number of active licences since one of them burnt via clan creation
  }

  function lordTaxInfo(uint256 _lordID) public view returns (address, uint256) {
    return (ownerOf(_lordID), baseTaxRate + (taxChangeRate * (numberOfGlories[_lordID])));
  }

}