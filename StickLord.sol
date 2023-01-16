// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./dependencies/ERC721.sol";
import "./dependencies/ERC721URIStorage.sol";
import "./dependencies/ERC721Burnable.sol";
import "./dependencies/Counters.sol";
import "./dependencies/IERC20.sol";
import "./dependencies/ERC20Burnable.sol";
import "./dependencies/IERC4907.sol";


/**
 * @notice
 * -> Executors can propose to change mint cost by FDAO approval.
  *
 * -> A Lord can mint maximum of 3 clan licenses. Once a licenses used by a clan leader to create
 * clan, the license burns and lord can mint a new license.
  *
 * -> Lords can set custom URI for their licenses
  *
 * -> Lords collects taxes from their clans. Initial tax rate is 10%. Which means, 10% of the clan rewards
 * will go to the lord of the clan.
  *
 * -> If the clans starts a rebellion and fails, tax rate increases according to formula below.
 * Tax rate formula: tax rate = base tax rate + (tax rate change * number of glories);
 * If the rebellion wins the war, lord dies and clans would be free. No more taxes!
 * War is a simply battle of resources. Lord or rebels should have at least 66% of funding to win.
 * 10% of the total funds in a war burns as war casualties. Remaining funds goes to the winner side.
 * Everyone can support the lord or rebels! Supporters of winner side shares the losers' funds after war!
  *
 * -> Lord NFTs are rentable. Lords can rent them out by setting renter address and expire date.
 * An owner can't rent out the NFT until the current expire date passes.
  *
 * -> The Lord Tax goes to the renter. If there no renter, tax goes to the owner.
 * The renter can't mint clan licenses but can vote for DAO proposals and collects taxes.
  *
 * -> Owner can rent out the Lord without any fee from the contract or another interfaces. Lords who want
 * to get rent fees in STICK tokens can use StickRent contract to rent them out.
 *
 * -> Upper limit of mint cost is 666$.
 */

/**
 * @author Bora
 */
contract StickLord is ERC721, ERC721Burnable {  
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;
  Counters.Counter private rebellionCounter;

  enum Status{
    NotStarted, // Index: 0
    OnGoing,    // Index: 1
    Approved,   // Index: 2
    Denied      // Index: 3
  }

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

  mapping(uint256 => uint256) public numberOfClans; // that the lord has | Lord ID => number of clans
  mapping(uint256 => uint256[]) public clansOf; // that the lord has | Lord ID => Clan IDs in array []
  // Lord ID => number of licensese in cirulation (not used therefore not burnt)
  mapping(uint256 => uint256) public numberOfActiveLicenses; 
  mapping(uint256 => uint256) public numberOfGlories; // Lord ID => number of glories
  mapping(uint256  => uint256) public rebellionOf;    // Lord ID => Rebellion ID
  mapping(uint256  => Rebellion) public rebellions;   // Rebellion ID => Rebellion
  mapping(uint256  => UserInfo) internal _users;      // People who rents

  string baseURI;
  address deployer;

  uint256 public totalSupply;
  uint256 public maxSupply;
  uint256 public baseMintCost;
  uint256 public mintCostIncrement;
  uint256 public baseTaxRate;     // Adjustable by DAO
  uint256 public taxChangeRate;   // Adjustable by DAO
  uint256 public rebellionLenght; // Adjustable by DAO
  uint256 public signalLenght;    // Adjustable by DAO
  uint256 public victoryRate;     // Adjustable by DAO  | The rate (%) of the funds that is required to declare victory against the lord 
  uint256 public warCasualtyRate; // Adjustable by DAO  | The rate (%) that will burn as a result of the war

  constructor(string memory _baseURI) ERC721("StickLord", "SLORD") {
    teamAndCommunityMint();       // Mint first 50 Lords for team and community allocation
    rebellionCounter.increment(); // Leave first (0) rebellion empty for all lords to start a new one

    maxSupply = 500;

    baseMintCost = 0.05 ether;  // TEST -> Change it with the final value - Initial cost to mint a Lord
    mintCostIncrement = 0.0005 ether;  // TEST -> Change it with the final value - Increases 0.0005 ETH with every mint

    baseTaxRate = 10;     // TEST -> Change it with the final value
    taxChangeRate = 7;    // TEST -> Change it with the final value

    rebellionLenght = 7 days;     // TEST -> Change it with the final value
    signalLenght = 3 days;        // TEST -> Change it with the final value
    victoryRate = 66;             // TEST -> Change it with the final value
    warCasualtyRate = 10;         // TEST -> Change it with the final value

    // TEST -> Add warning in the decription of metedata that says "If you earn taxes and vote in DAO,
    // check if the lord is rented to another address before you buy! Click the link below and use isRented()
    // funtion to check" and put the contract's read link.
    baseURI = _baseURI;  

    // Test
    deployer = _msgSender(); 
  }

  event UpdateUser(uint256 indexed tokenId, address indexed user, uint256 expires);

  receive() external payable {}

  fallback() external payable {}

  function withdrawLpFunds() public payable {
    payable(deployer).transfer(address(this).balance);
  }

  function _burn(uint256 tokenId) internal override {
    totalSupply--;
    super._burn(tokenId);
  }

  function teamAndCommunityMint() internal {
    _tokenIdCounter.increment();  // Start the token ID from 1 by increasing the counter initially

    // Mint first 50 Lords for the deployer address
    for (uint tokenId = 1; tokenId <= 50; tokenId++) {      
      _safeMint(_msgSender(), tokenId);

      _tokenIdCounter.increment();
      totalSupply++;
    }
  }

  function lordMint() public payable {
    uint256 tokenId = _tokenIdCounter.current();

    // Calculate the current mint cost
    uint256 mintCost = baseMintCost + ((tokenId - 50) * mintCostIncrement);

    require(tokenId <= maxSupply, "Sorry mate, there can ever be only 500 Lords, and they are all out!");
    require(msg.value >= mintCost, "Not sufficient mint cost!");   
    
    _tokenIdCounter.increment();            // Increase the ID counter
    totalSupply++;                          // Increase the totalSupply
    _safeMint(_msgSender(), tokenId);       // Mint the Lord
    
    uint256 change = msg.value - mintCost;  // Get the change
    payable(_msgSender()).transfer(change); // Return the change
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(string memory _newURI) public { // TEST make it with DAO approval
    baseURI = _newURI;
  }

  function mintClanLicense(uint256 _lordID, uint256 _amount, bytes memory _data) public {
    require(ownerOf(_lordID) == _msgSender(), "Who are you fooling? You are not the Lord that you claim to be!");
    
    bytes memory payload = abi.encodeWithSignature("mintLicense(address,uint256,uint256,bytes)", _msgSender(), _lordID, _amount, _data);
    (bool txSuccess, ) = address(contracts[2]).call(payload);
    require(txSuccess, "Transaction has fail to mint new license from the License contract!");
  }

  function setCustomLicenseURI(uint256 _lordID, string memory _newURI) public {
    require(ownerOf(_lordID) == _msgSender(), "Who are you fooling? You are not the Lord that you claim to be!");

    bytes memory payload = abi.encodeWithSignature("setCustomURI(uint256,string)", _lordID, _newURI);
    (bool txSuccess, ) = address(contracts[2]).call(payload);
    require(txSuccess, "Transaction has fail to set a new URI for the License!");
  }

  function clanRegistration(uint256 _lordID, uint256 _clanID) public {
    require(_msgSender() == contracts[1], "Only the Clan contract can call this function! Now, back off you domass!");

    clansOf[_lordID].push(_clanID);     // Keep the record of the clan ID
    numberOfActiveLicenses[_lordID]--;  // Reduce the number of active licenses since one of them burnt via clan creation
  }

  function DAOvote(uint256 _proposalID, bool _isApproving, uint256 _lordID) public {
    require(userOf(_lordID) == _msgSender(), "Who are you fooling? You have no right to vote for this Lord!");

    bytes memory payload = abi.encodeWithSignature(
      "lordVote(uint256,bool,uint256,uint256)", _proposalID, _isApproving, _lordID, totalSupply
    );
    (bool txSuccess, ) = contracts[4].call(payload);
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
    require(_msgSender() == contracts[1], "Only clans can call this function!");
    require(clansOf[_lordID].length >= 3, "You can't start rebellion unless there are at least 3 clans!");
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
      ERC20Burnable(contracts[11]).burn(casualties);
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

    ERC20(contracts[11]).transferFrom(_msgSender(), address(this), _amount);

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

    ERC20(contracts[11]).transferFrom(_msgSender(), address(this), _amount);

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
      ERC20(contracts[11]).transfer(sender, trophy);
    }
    // If it is not successful, it must be failed. But it can fail without and funding because of lack of signals.
    // Therefore, check is there any fund to send to avoid unnecessary gas usage
    else if (reb.totalFunds > 0) {
      require(reb.lordBackerClaimed[sender] == false, "You already claimed!");
      reb.lordBackerClaimed[sender] = true;

      uint256 contributionRate = reb.lordBackers[sender] * 100 / reb.lordFunds;
      uint256 trophy = reb.totalFunds * contributionRate / 100;
      ERC20(contracts[11]).transfer(sender, trophy);
    }
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * baseTaxRate -> Code: 3
   * taxChangeRate -> Code: 4
   * rebellionLenght -> Code: 5
   * signalLenght -> Code: 6
   * victoryRate -> Code: 7
   * warCasualtyRate -> Code: 8
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
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
      "In Lord contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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

  function proposeBaseTaxRateUpdate(uint256 _newBaseTaxRate) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating Base Tax Rate to ", 
      Strings.toHexString(_newBaseTaxRate), " from ", Strings.toHexString(baseTaxRate), "."
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
    proposals[propID].newUint = _newBaseTaxRate;
  }

  function executeBaseTaxRateProposal(uint256 _proposalID) public {
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
      baseTaxRate = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeTaxChangeRateUpdate(uint256 _newTaxChangeRate) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating Tax Rate Change to ", 
      Strings.toHexString(_newTaxChangeRate), " from ", Strings.toHexString(taxChangeRate), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 4;
    proposals[propID].newUint = _newTaxChangeRate;
  }

  function executeTaxRateChangeProposal(uint256 _proposalID) public {
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
      taxChangeRate = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeRebellionLenghtUpdate(uint256 _newRebellionLenght) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating Rebellion Lenght to ", 
      Strings.toHexString(_newRebellionLenght), " from ", Strings.toHexString(rebellionLenght), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 5;
    proposals[propID].newUint = _newRebellionLenght;
  }

  function executeRebellionLenghtProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 5 && !proposal.isExecuted, "Wrong proposal ID");

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
      rebellionLenght = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeSignalLenghtUpdate(uint256 _newSignalLenght) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating Signal Lenght to ", 
      Strings.toHexString(_newSignalLenght), " from ", Strings.toHexString(signalLenght), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 6;
    proposals[propID].newUint = _newSignalLenght;
  }

  function executeSignalLenghtProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 6 && !proposal.isExecuted, "Wrong proposal ID");

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
      signalLenght = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeVictoryRateUpdate(uint256 _newVictoryRate) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating Victory Rate to ", 
      Strings.toHexString(_newVictoryRate), " from ", Strings.toHexString(victoryRate), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 7;
    proposals[propID].newUint = _newVictoryRate;
  }

  function executeVictoryRateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 7 && !proposal.isExecuted, "Wrong proposal ID");

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
      victoryRate = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeWarCasualtyRateUpdate(uint256 _newWarCasualtyRate) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Lord contract, updating War Casualty Rate to ", 
      Strings.toHexString(_newWarCasualtyRate), " from ", Strings.toHexString(warCasualtyRate), "."
    )); 

    // Create a new proposal - DAO (contracts[4]) - Moderately Important Proposal (proposalTypes[1])
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Get the ID
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the local proposal
    proposals[propID].updateCode = 8;
    proposals[propID].newUint = _newWarCasualtyRate;
  }

  function executeWarCasualtyRateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 8 && !proposal.isExecuted, "Wrong proposal ID");

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
      warCasualtyRate = proposal.newUint;

    proposal.isExecuted = true;
  }
}