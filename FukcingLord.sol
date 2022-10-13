// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./IERC4907.sol";
/**
  * -> Rebellion Mechanism
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
  * -> Rentable: Set user and end time as unix.
  */

contract FukcingLord is ERC721, ERC721Burnable {  
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  struct UserInfo {
    address user;   // address of user role
    uint256 expires; // unix timestamp, user expires
  }

  mapping(uint256 => uint256) public numberOfClans; // that the lord has | Lord ID => number of clans
  mapping(uint256 => uint256[]) public clansOf; // that the lord has | Lord ID => Clan IDs in array []
  // Lord ID => number of licencese in cirulation (not used therefore not burnt)
  mapping(uint256 => uint256) public numberOfActiveLicences; 
  mapping(uint256 => uint256) public numberOfGlories;
  mapping (uint256  => UserInfo) internal _users;   // People who rents

  address public fukcingExecutors;
  address public fukcingDAO;
  address public fukcingToken;
  address public fukcingClan;
  address public fukcingClanLicence;

  string baseURI;

  uint256 public totalSupply;
  uint256 public maxSupply;
  uint256 public mintCost;
  uint256 public baseTaxRate;
  uint256 public taxChangeRate;

  constructor(string memory _baseURI) ERC721("FukcingLord", "FLORD") {
    _tokenIdCounter.increment();
    maxSupply = 666;
    mintCost = 66 ether;  // TEST -> Change it with the final value
    baseTaxRate = 13;     // TEST -> Change it with the final value
    taxChangeRate = 7;    // TEST -> Change it with the final value
    
    // TEST -> Add warning in the decription of metedata that says "If you earn taxes and vote in DAO,
    // check if the lord is rented to another address before you buy! Click the link below and use isRented()
    // funtion to check" and put the contract's read link.
    baseURI = _baseURI;   
  }


  event UpdateUser(uint256 indexed tokenId, address indexed user, uint256 expires);

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

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(string memory _newURI) public { // TEST make it with DAO approval
    baseURI = _newURI;
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

  function DAOvote(uint256 _proposalID, bool _isApproving, uint256 _lordID) public {
    require(userOf(_lordID) == _msgSender(), "Who are you fooling? You have no right to vote for this Fukcing Lord!");

    bytes memory payload = abi.encodeWithSignature(
      "lordVote(uint256,bool,uint256,uint256)", _proposalID, _isApproving, _lordID, totalSupply
    );
    (bool txSuccess, ) = fukcingDAO.call(payload);
    require(txSuccess, "Transaction has fail to vote in DAO contract!");
  }

  /// @notice userOf function returns the renter or the owner if there is no current renter.
  /// Therefore the tax goes to the renter. If there is no renter, the tax goes to the owner. See userOf()
  function lordTaxInfo(uint256 _lordID) public view returns (address, uint256) {
    return (userOf(_lordID), baseTaxRate + (taxChangeRate * (numberOfGlories[_lordID])));
  }

  /// @notice set the user and expires of an NFT IF the current user's time has expired
  /// @dev The zero address indicates there is no user
  /// Throws if `tokenId` is not valid NFT
  /// @param user  The new user of the NFT
  /// @param expires  UNIX timestamp, The new user could use the NFT before expires
  function setUser(uint256 tokenId, address user, uint256 expires) public virtual{
    require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
    require(block.timestamp > _users[tokenId].expires, 
      "You can't rent it again untill the end of the expire date of current user!"
    );

    UserInfo storage info =  _users[tokenId];
    info.user = user;
    info.expires = expires;
    emit UpdateUser(tokenId,user,expires);
  }

  /// @notice Get the user address of an NFT
  /// @dev The zero address indicates that there is no user or the user is expired
  /// @param tokenId The NFT to get the user address for
  /// @return The user address for this NFT. There is no user, then returns the owner address
  function userOf(uint256 tokenId)public view virtual returns(address){
    if(_users[tokenId].expires >=  block.timestamp){
      return  _users[tokenId].user;
    }
    else{
      return ownerOf(tokenId);
    }
  }

  /// @notice Get the user expires of an NFT
  /// @dev The zero value indicates that there is no user
  /// @param tokenId The NFT to get the user expires for
  /// @return The user expires for this NFT
  function userExpires(uint256 tokenId) public view virtual returns(uint256){
    return _users[tokenId].expires;
  }

  /// @dev See {IERC165-supportsInterface}.
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
  }

  function isRented(uint256 _lordID) public view returns (bool) {
    return _users[_lordID].expires >= block.timestamp;
  }
}