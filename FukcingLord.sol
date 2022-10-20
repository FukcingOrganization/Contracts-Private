// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./IERC4907.sol";
/**
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
  * -> Rentable: Set user and end time as unix. Can't rent to someone else until the expire date
  * -> Rebellion Mechanism: kills the lord if the rebllion successful, raises the taxes if the rebellion failes.
  * ---> 13% of the total funds burns as a consequense of the war, remaining gets claimed by winner side.
  */

contract FukcingLord is ERC721, ERC721Burnable {  
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;
  Counters.Counter private rebellionCounter;

  enum RebellionStatus {    
    NotStarted, // Index: 0
    Signaled,   // Index: 1
    OnGoing,    // Index: 2
    Success,    // Index: 3
    Failed      // Index: 4
  }

  struct Rebellion {
    RebellionStatus status;
    uint256 startDate;

    uint256 lordFunds;
    uint256 rebelFunds;
    uint256 totalFunds;
    mapping(address => uint256) lordBackers;  // Addresses that funds the lord during war    
    mapping(address => uint256) rebelBackers; // Addresses that funds the rebels during war 
    mapping(address => bool) lordBackerClaimed;  // Addresses that claimed the war trophy
    mapping(address => bool) rebelBackerClaimed;

    uint256 numberOfSignaledClans;  
    mapping(uint256 => bool) signaledClans; // Clans that signaled for this rebellion    
  }

  struct UserInfo {
    address user;   // address of user role
    uint256 expires; // unix timestamp, user expires
  }

  mapping(uint256 => uint256) public numberOfClans; // that the lord has | Lord ID => number of clans
  mapping(uint256 => uint256[]) public clansOf; // that the lord has | Lord ID => Clan IDs in array []
  // Lord ID => number of licencese in cirulation (not used therefore not burnt)
  mapping(uint256 => uint256) public numberOfActiveLicences; 
  mapping(uint256 => uint256) public numberOfGlories; // Lord ID => number of glories
  mapping(uint256  => uint256) public rebellionOf;    // Lord ID => Rebellion ID
  mapping(uint256  => Rebellion) public rebellions;   // Rebellion ID => Rebellion
  mapping(uint256  => UserInfo) internal _users;      // People who rents

  address public fukcingExecutors;    // Adjustable by DAO
  address public fukcingDAO;          // Adjustable by DAO
  address public fukcingToken;        // Adjustable by DAO
  address public fukcingClan;         // Adjustable by DAO
  address public fukcingClanLicence;  // Adjustable by DAO

  string baseURI;

  uint256 public totalSupply;
  uint256 public maxSupply;
  uint256 public mintCost;
  uint256 public baseTaxRate;     // Adjustable by DAO
  uint256 public taxChangeRate;   // Adjustable by DAO
  uint256 public rebellionLenght; // Adjustable by DAO
  uint256 public signalLenght;    // Adjustable by DAO
  uint256 public victoryRate;     // Adjustable by DAO  | The rate (%) of the funds that is required to declare victory against the lord 
  uint256 public warCasualtyRate; // Adjustable by DAO  | The rate (%) that will burn as a result of the war

  constructor(string memory _baseURI) ERC721("FukcingLord", "FLORD") {
    _tokenIdCounter.increment();  // token IDs starts from 1 and goes to 666
    rebellionCounter.increment(); // Leave first (0) rebellion empty for all lords to start a new one
    maxSupply = 666;
    mintCost = 66 ether;  // TEST -> Change it with the final value
    baseTaxRate = 13;     // TEST -> Change it with the final value
    taxChangeRate = 7;    // TEST -> Change it with the final value
    rebellionLenght = 7 days;     // TEST -> Change it with the final value
    signalLenght = 3 days;        // TEST -> Change it with the final value
    victoryRate = 66;             // TEST -> Change it with the final value
    warCasualtyRate = 13;         // TEST -> Change it with the final value

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
  /// If the lord has died or not even minted, than returns 0 address and 0 rate for clan contract not to fail.
  function lordTaxInfo(uint256 _lordID) public view returns (address, uint256) {
    if (_exists(_lordID))
      return (userOf(_lordID), baseTaxRate + (taxChangeRate * (numberOfGlories[_lordID])));
    else
      return (address(0), 0);
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

  function signalRebellion(uint256 _lordID, uint256 _clanID) public {
    require(_msgSender() == fukcingClan, "Only clans can call this function!");
    require(clansOf[_lordID].length >= 13, "You can't start rebellion unless there are at least 13 clans!");
    require(_exists(_lordID), "This lord doesn't exists!");

    Rebellion storage reb = rebellions[rebellionOf[_lordID]];
    updateRebellionStatus(reb, _lordID);

    // Take the updated rebellion again
    reb = rebellions[rebellionOf[_lordID]];

    require(reb.status == RebellionStatus.Signaled, "The rebellion is not in the signal phase!");
    require(reb.signaledClans[_clanID] == false, "You guys already signeled for this rebellion!");
    
    reb.signaledClans[_clanID] = true;  // mark them signelled
    reb.numberOfSignaledClans++;
  }
  
  function updateRebellionStatus(Rebellion storage _reb, uint256 _lordID) internal {
    // Determine timing status
    bool isSingalPhase = _reb.startDate + signalLenght > block.timestamp;
    bool isRebelPhase = _reb.startDate + rebellionLenght > block.timestamp;

    // If the status NotStarted or is finalized (Success or Fail, 2 < index) start the rebellion
    if (_reb.status == RebellionStatus.NotStarted || uint256(_reb.status) > 2) {
      rebellionOf[_lordID] = rebellionCounter.current();
      rebellionCounter.increment();
      
      // Get the new rebellion and start it
      Rebellion storage reb = rebellions[rebellionOf[_lordID]];
      reb.status = RebellionStatus.Signaled;
      reb.startDate = block.timestamp;
    }
    // Else if the signal phase ended but rebel phase continious, mark it on going
    else if (!isSingalPhase && isRebelPhase){
      // If there more than half of the clans signaled, then start the rebellion. If not, update it as failed
      if (_reb.numberOfSignaledClans > (clansOf[_lordID].length / 2))
        _reb.status = RebellionStatus.OnGoing;
      else
        _reb.status = RebellionStatus.Failed;
    }
    // Else if rebel phase ended but the status is OnGoing, then determine the final status
    else if (!isRebelPhase && _reb.status == RebellionStatus.OnGoing) {
      uint256 rate = _reb.rebelFunds * 100 / (_reb.rebelFunds + _reb.lordFunds);
      if (rate >= victoryRate) {        
        _reb.status = RebellionStatus.Success;

        // Kill (burn) the lord!
        _burn(_lordID);
      }
      else {
        _reb.status = RebellionStatus.Failed;

        // Keep record of glory
        numberOfGlories[_lordID]++;
      }

      // Either way, burn some of the total funds as a war casualties
      uint256 casualties = _reb.totalFunds * warCasualtyRate / 100;
      ERC20Burnable(fukcingToken).burn(casualties);
      _reb.totalFunds -= casualties;
    }
  }

  function fundLord(uint256 _lordID, uint256 _amount) public {
    require(_exists(_lordID), "This lord doesn't exists!");

    Rebellion storage reb = rebellions[rebellionOf[_lordID]];
    updateRebellionStatus(reb, _lordID);

    // Take the updated rebellion again
    reb = rebellions[rebellionOf[_lordID]];
    require(reb.status == RebellionStatus.OnGoing, "The rebellion is not on going!");

    ERC20(fukcingToken).transferFrom(_msgSender(), address(this), _amount);

    reb.lordFunds += _amount;
    reb.totalFunds += _amount;
    reb.lordBackers[_msgSender()] += _amount;
  }

  function fundRebels(uint256 _lordID, uint256 _amount) public {
    require(_exists(_lordID), "This lord doesn't exists!");

    Rebellion storage reb = rebellions[rebellionOf[_lordID]];
    updateRebellionStatus(reb, _lordID);

    // Take the updated rebellion again
    reb = rebellions[rebellionOf[_lordID]];
    require(reb.status == RebellionStatus.OnGoing, "The rebellion is not on going!");

    ERC20(fukcingToken).transferFrom(_msgSender(), address(this), _amount);

    reb.rebelFunds += _amount;
    reb.totalFunds += _amount;
    reb.rebelBackers[_msgSender()] += _amount;
  }

  function claimRebellionRewards(uint256 _rebellionID, uint256 _lordID) public {
    require(_lordID >= totalSupply, "This lord has not minted yet!");
    address sender = _msgSender();

    Rebellion storage reb = rebellions[_rebellionID];
    updateRebellionStatus(reb, _lordID);

    // Take the updated rebellion again
    reb = rebellions[_rebellionID];
    require(uint256(reb.status) > 2, "The rebellion is not finalized!");

    if (reb.status == RebellionStatus.Success) {
      require(reb.rebelBackerClaimed[sender] == false, "You already claimed!");
      reb.rebelBackerClaimed[sender] = true;

      uint256 contributionRate = reb.rebelBackers[sender] * 100 / reb.rebelFunds;
      uint256 trophy = reb.totalFunds * contributionRate / 100;
      ERC20(fukcingToken).transfer(sender, trophy);
    }
    // If it is not successful, it must be failed. But it can fail without and funding because of lack of signals.
    // Therefore, check is there any fund to send to avoid unnecessary gas usage
    else if (reb.totalFunds > 0) {
      require(reb.lordBackerClaimed[sender] == false, "You already claimed!");
      reb.lordBackerClaimed[sender] = true;

      uint256 contributionRate = reb.lordBackers[sender] * 100 / reb.lordFunds;
      uint256 trophy = reb.totalFunds * contributionRate / 100;
      ERC20(fukcingToken).transfer(sender, trophy);
    }
  }
}