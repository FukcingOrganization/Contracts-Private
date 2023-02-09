// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
  @notice
  - To create clan, you need a clan license. When you create a clan, your clan license burns.
  
  - By default, everyone is a member of every clan. An address is an actual member if and only if 
  the member has at least 1 point in the clan. Therefore, clan leaders or executors should give at 
  least 1 point to all members to indicate them as members. Setting a member's point to 0 means 
  kicking it out of the clan. 
  
  - Only the leader can update clan name, description, motto, and logo.
  
  - Clan leader can set any member as an executor to set members point and signal rebellion.
  This will help clan leaders to reach large number of members.
  
  - When we enter a new round timeline, first clan that claims the reward triggers the round.
  
  - Clan leaders sets the members point and all members gets their clan reward based on their
  member point compared to total member point.
  
  - Executors and Stick DAO increases or decreases the point of clans. Executors doesn't need a
  DAO approval to increase or decrease point of a clan. If DAO considers there has been a violation
  of rights, DAO can start an proposal to take action. Executors and DAO have a maxiumum limit to change
  point of a clan. DAO will have 3 days long proposal to make changes and Executors will have 6 days
  cool down to make changes.
  
  - Total clan rewards is limited by total supply of SDAO tokens. This incentivizes the DAO members
  who are most likely the clans members to approve new SDAO token mints to expand DAO's member base and
  increases decentralization of DAO.
  
  - Executors can propose to update contract addresses, proposal types, cooldown time, and maximum 
  point to change at a time.
  */

/// @author Bora

interface IDAO {
  function newProposal(string memory _description, uint256 _proposalType) external returns(uint256);
  function proposalResult(uint256 _proposalID) external returns(uint256);
  function getMinBalanceToPropose() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function mintTokens(address _minter, uint256 _amount) external;
}

interface IRound {
  function getCurrentRoundNumber() external returns (uint256);
}

interface ILord {
  function clanRegistration(uint256 _lordID, uint256 _clanID) external;
  function lordTaxInfo(uint256 _lordID) external view returns (address, uint256);
  function signalRebellion(uint256 _lordID, uint256 _clanID) external;
}

interface IToken {
  function clanMint() external returns (uint256);
}

contract StickClan is Context, ReentrancyGuard {
  using Counters for Counters.Counter;

  struct MemberInfo {
    bool isMember;
    bool isExecutor;
    bool isMod;
    mapping(uint256 => uint256) point;   // Round Number => point
  }

  struct ClanInfo {
    // Clan foundation info
    address leader;
    uint256 lordID;
    uint256 firstRound;

    // Clan display info
    string name;
    string description;
    string motto;
    string logoURI;

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoint;
    bool canModerateMembers;
    bool isDisbanded;
  }

  struct Clan {
    ClanInfo info;

    // Clan point and balance
    uint256 proposal_ID;
    uint256 balance;        
    uint256 maxMemberCount;        
    address[] members;
    mapping(address => MemberInfo) member;
    Counters.Counter memberCounter;

    // Round Number => value
    mapping(uint256 => uint256) point;   // Keep clan point for clan to claim
    mapping(uint256 => uint256) rewards;  // Keep reward for members to claim
    mapping(uint256 => uint256) totalMemberPoint; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Round Number => Address => isclaimed?
    mapping(uint256 => uint256) claimedRewards;     // Total claimed rewards by members in a round
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

  struct Round {
    uint256 totalClanPoint;                 // Total clan pts at the time
    uint256 clanRewards;                    // Total clan reward at the time
    uint256 claimedRewards;                 // Total claimd reward at the time
    mapping(uint256 => bool) isClanClaimed; // Clan ID => is claimed?
  }
  
  Counters.Counter public clanCounter;

  /** 
    If we want to change a function's proposal type, then we can simply change its type index

    Index : Associated Function
    0: Contract address update
    1: Functions Proposal Types update
    2: Max point to change
    3: Cooldown time update
    4: Min Balance to Clan Point Change
    5: Clan Point Adjustment
  */
  uint256[6] public functionsProposalTypes;

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
  mapping(uint256 => Round) public rounds;      // Proposal Number => Round
  mapping(uint256 => Clan) public clans;          // Clan ID => Clan info
  mapping(address => uint256) public declaredClan;      // ID of the clan of an address
  mapping(uint256 => uint256) public clanCooldownTime;  // Cooldown time for each clan | Clan ID => Cooldown time
  mapping(address => mapping(uint256 => uint256)) public collectedTaxes;  // Receiver => Lord ID => Amount

  uint256 public maxPointToChange;        // Maximum point that can be given in a propsal
  uint256 public cooldownTime;            // Cool down time to give clan point by executors
  uint256 public roundNumber;             // Tracking the round number
  uint256 public minBalanceToProposeClanPointChange;  // Amount of tokens without decimals

  constructor(address[13] memory _contracts){
    contracts = _contracts;  // Set the existing contracts
    clanCounter.increment();  // clan ID's should start from 1
    maxPointToChange = 666;
    cooldownTime = 10 minutes; // TEST -> (7 days / 2);
    minBalanceToProposeClanPointChange = 100 ether;

    roundNumber = 1;  // Round number starts from 1
  }

  function DEBUG_setContract(address _contractAddress, uint256 _index) public {
    contracts[_index] = _contractAddress;
  }

  function DEBUG_setContracts(address[13] memory _contracts) public {
    contracts = _contracts;
  }

  //////// View Functions ////////
  ///@dev returns true if the clan claimed its reward for a specific round
  function viewIsClanClaimed(uint256 _roundNumber, uint256 _clanID) public view returns(bool) {
    return rounds[_roundNumber].isClanClaimed[_clanID];
  }

  ///@dev returns true if the member address claimed its reward for a specific round
  function viewIsMemberClaimed(uint256 _roundNumber, uint256 _clanID, address _memberAddress) public view returns(bool) {
    return clans[_clanID].isMemberClaimed[_roundNumber][_memberAddress];
  }

  ///@dev returns total and claimed rewards for a specific round
  function viewClanRewards(uint256 _roundNumber, uint256 _clanID) public view returns(uint256, uint256) {
    return (clans[_clanID].rewards[_roundNumber], clans[_clanID].claimedRewards[_roundNumber]);
  }

  ///@dev returns current and max clan member amount
  function viewClanRewards(uint256 _clanID) public view returns(uint256, uint256) {
    return (clans[_clanID].memberCounter.current(), clans[_clanID].maxMemberCount);
  }

  ///@dev returns current and max clan member amount
  function viewClanInfo(uint256 _clanID) public view returns(
    address, uint256, uint256, 
    string memory, string memory, string memory, string memory, 
    bool, bool, bool, bool) 
  {
    ClanInfo storage info = clans[_clanID].info;
    return (info.leader, info.lordID, info.firstRound, 
      info.name, info.description, info.motto, info.logoURI, 
      info.canExecutorsSignalRebellion, 
      info.canExecutorsSetPoint, 
      info.canModerateMembers, 
      info.isDisbanded
    );
  }

  ///@dev returns current and max clan member amount
  function getClanBalance(uint256 _clanID) public view returns(uint256) {
    return (clans[_clanID].balance);
  }
  
  ///@dev Returns the real clan of an address. Only members with point are real members, others are default
  function getClanOf(address _address) public view returns (uint256) {
    Clan storage clan = clans[declaredClan[_address]];
    return clan.member[_address].isMember ? declaredClan[_address] : 0;
  }

  ///@dev Returns true if the member is an executor in its clan
  function isMemberExecutor(address _memberAddress) public view returns (bool) {
    Clan storage clan = clans[declaredClan[_memberAddress]];
    return clan.member[_memberAddress].isExecutor;
  }

  ///@dev Returns true if the member is an executor in its clan
  function isMemberMod(address _memberAddress) public view returns (bool) {
    Clan storage clan = clans[declaredClan[_memberAddress]];
    return clan.member[_memberAddress].isMod;
  }

  ///@dev Returns the member's point
  function getMemberPoint(address _memberAddress) public returns (uint256) {
    uint256 clanID = declaredClan[_memberAddress];
    MemberInfo storage member = clans[declaredClan[_memberAddress]].member[_memberAddress];

    // Update clan point before interact with them.
    updatePointAndRound(clanID, _memberAddress); 

    return member.point[roundNumber];
  }

  ///@dev returns Total Clan Point, Clan Point, Total Member Point, Member Addresses, Member Points, isMemberActive, isMemberExecutor, isMemberMod
  function getClanPoints(uint256 _clanID) public view returns 
    (uint256, uint256, uint256, address[] memory, uint256[] memory, bool[] memory, bool[] memory, bool[] memory) 
  {
    Clan storage clan = clans[_clanID];
    //MemberInfo storage member = clans[_clanID].members[_address];

    bool[] memory isMemberActive  = new bool[](clan.maxMemberCount);
    bool[] memory isMemberExecutor  = new bool[](clan.maxMemberCount);
    bool[] memory isMemberMod  = new bool[](clan.maxMemberCount);
    uint256[] memory memberPoints  = new uint[](clan.maxMemberCount);

    for (uint256 count = 0; count < clan.maxMemberCount; count++) {
      MemberInfo storage member = clan.member[clan.members[count]]; // Get each registered member

      isMemberActive[count] = member.isMember;
      isMemberExecutor[count] = member.isExecutor;
      isMemberMod[count] = member.isMod;
      memberPoints[count] = member.point[roundNumber];
    }

    return (rounds[roundNumber].totalClanPoint, clan.point[roundNumber], clan.totalMemberPoint[roundNumber], clan.members, memberPoints, isMemberActive, isMemberExecutor, isMemberMod);
  }

  function createClan(
    uint256 _lordID, 
    string memory _clanName, 
    string memory _clanDescription, 
    string memory _clanMotto, 
    string memory _clanLogoURI
  ) 
  public nonReentrant() {
    // Burn license to create a clan | lord ID = license ID
    // If caller can burn it, then the clan will be attached to the lord with same ID
    ERC1155Burnable(contracts[2]).burn(_msgSender() ,_lordID , 1);

    uint256 clanID = clanCounter.current();

    // Register the clan to the lord
    ILord(contracts[7]).clanRegistration(_lordID, clanID);

    // Create the clan
    Clan storage clan = clans[clanID];
    clanCounter.increment();

    clan.info.leader = _msgSender();
    clan.info.lordID = _lordID;
    clan.info.name = _clanName;
    clan.info.description = _clanDescription;
    clan.info.motto = _clanMotto;
    clan.info.logoURI = _clanLogoURI;
    clan.members.push(_msgSender());
    clan.info.firstRound = roundNumber;

    // Sign the leader as a member of the clan as well and give full authority
    clan.member[_msgSender()].isMember = true;
    clan.member[_msgSender()].isExecutor = true;
    clan.member[_msgSender()].isMod = true;

    clan.memberCounter.increment(); // Increament the counter to 1 from 0
    clan.maxMemberCount++;
  }

  function declareClan(uint256 _clanID) public {
    require(clans[_clanID].info.leader != address(0), "There is no such clan with that ID!");
    require(!clans[_clanID].info.isDisbanded, "This clan is disbanded!");
    
    address sender = _msgSender();
    Clan storage currClan = clans[declaredClan[sender]];

    // Erase data from the current clan
    if (currClan.member[sender].isMember) {
      currClan.member[sender].isMember = false;
      currClan.member[sender].isExecutor = false;
      currClan.member[sender].isMod = false;
      currClan.memberCounter.decrement();
    }

    // Keep record of the new clan ID of the address
    // Note: By default, everyone a member of all clans. Being a true member requires at least 1 point.
    declaredClan[sender] = _clanID; 
  }

  /**
    @dev Only the Executors can give clan point. 
    There is a cooldown time to avoid executors change clan point as they wish.
    Executors can give clan point on for the current round.
  */
  function giveClanPoint(uint256 _clanID, uint256 _point, bool _isDecreasing) public {
    require(_msgSender() == contracts[5], "Only Executors can call this function!"); 
    require(_point <= maxPointToChange, "Maximum amount of point exceeded!");
    require(!clans[_clanID].info.isDisbanded, "This clan is disbanded!");
    
    // Wait if the cooldown time is not passed. Avoids executors to change point as they wish!
    require(block.timestamp > clanCooldownTime[_clanID], "Wait for the cooldown time!");
    clanCooldownTime[_clanID] = block.timestamp + cooldownTime; // set a new cooldown time

    // Update clan point before interact with them. Not member (0)
    updatePointAndRound(_clanID, address(0));

    Clan storage clan = clans[_clanID];
    
    if (_isDecreasing){
      clan.point[roundNumber] -= _point;
      rounds[roundNumber].totalClanPoint -= _point;
    }
    else {
      clan.point[roundNumber] += _point;
      rounds[roundNumber].totalClanPoint += _point;
    }
  }
  
  function giveBatchClanPoints(uint256[] memory _clanIDs, uint256[] memory _points, bool[] memory _isDecreasing) public {
    require(_msgSender() == contracts[5], "Only Executors can call this function!"); 

    for(uint256 i = 0; i < _clanIDs.length; i++) {      
      require(_points[i] <= maxPointToChange, "Maximum amount of point exceeded!");
      require(!clans[_clanIDs[i]].info.isDisbanded, "This clan is disbanded!");
      
      // Wait if the cooldown time is not passed. Avoids executors to change point as they wish!
      require(block.timestamp > clanCooldownTime[_clanIDs[i]], "Wait for the cooldown time!");
      clanCooldownTime[_clanIDs[i]] = block.timestamp + cooldownTime; // set a new cooldown time

      // Update clan point before interact with them. Not member (0)
      updatePointAndRound(_clanIDs[i], address(0));

      Clan storage clan = clans[_clanIDs[i]];
      
      if (_isDecreasing[i]){
        clan.point[roundNumber] -= _points[i];
        rounds[roundNumber].totalClanPoint -= _points[i];
      }
      else {
        clan.point[roundNumber] += _points[i];
        rounds[roundNumber].totalClanPoint += _points[i];
      }
    }
  }

  function clanRewardClaim(uint256 _clanID, uint256 _roundNumber) internal {    
    require(!rounds[_roundNumber].isClanClaimed[_clanID], "Your clan already claimed its reward for this round!");
    rounds[_roundNumber].isClanClaimed[_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // total clan reward * (clan Point * 100 / total clan point) / 100
    uint256 reward = rounds[_roundNumber].clanRewards * (clan.point[_roundNumber] * 100 / rounds[_roundNumber].totalClanPoint) / 100;
    rounds[_roundNumber].claimedRewards += reward;  // Keep record of the claimed rewards

    // Get the address and the tax rate of the lord
    (address lordAddress, uint256 taxRate) = ILord(contracts[7]).lordTaxInfo(clan.info.lordID);

    // Get the lord tax and update the reward after tax //
    uint256 lordTax = reward * taxRate / 100;
    reward -= lordTax;

    // Then transfer the taxes if there lord address exist. (which means lord is alive)
    if (lordAddress != address(0)){      
      IERC20(contracts[11]).transfer(lordAddress, lordTax);

      // Mint SDAO tokens as much as the lord tax reward
      IDAO(contracts[4]).mintTokens(lordAddress, lordTax);
    }

    // Then keep the remaining for the clan
    clan.rewards[_roundNumber] = reward;
    clan.balance += reward;
  }

  function memberRewardClaim(uint256 _clanID, uint256 _roundNumber) public {
    address sender = _msgSender();

    // Update clan point and round before interact with them.
    updatePointAndRound(_clanID, sender);  

    Clan storage clan = clans[_clanID];
    
    require(clan.member[sender].isMember, "You are not a member of this clan!");
    // TEST: Set the final value: Now, you can only claim clan rewards after 2 rounds to ensure your earnings! 
    require(_roundNumber < roundNumber - 0/** 2 */, "You can't claim the reward until it finalizes. Rewards are getting finalized after 3 rounds!");
    require(!clan.isMemberClaimed[_roundNumber][sender], "You already claimed your reward for this round!");
    clan.isMemberClaimed[_roundNumber][sender] == true;  // If not claimed yet, mark it claimed.


    // if clan reward is not claimed by clan executors or the leader, claim it.
    if (clan.rewards[_roundNumber] == 0) { clanRewardClaim(_clanID, _roundNumber); }      

    // calculate the reward and send it to the member!
    uint256 reward = // total reward of the clan * (member Point * 100 / total member point of the clan) / 100
      clan.rewards[_roundNumber] * (clan.member[sender].point[_roundNumber] * 100 / clan.totalMemberPoint[_roundNumber]) / 100;

    IERC20(contracts[11]).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
    clan.claimedRewards[_roundNumber] += reward; // Update the claimed rewards

    // Mint SDAO tokens as much as the clan member reward
    IDAO(contracts[4]).mintTokens(sender, reward);
  }

  /// @dev Starts the new round if the time is up
  function checkAndUpdateRound() public {
    uint256 currentRound = IRound(contracts[9]).getCurrentRoundNumber();

    // If the new round has started, get rewards from StickToken contract first
    if (currentRound > roundNumber){ 
      // Get the clans rewards from token
      rounds[roundNumber].clanRewards = IToken(contracts[11]).clanMint();

      // Pass on the current total clan point to the next round
      rounds[currentRound].totalClanPoint = rounds[roundNumber].totalClanPoint;

      roundNumber = currentRound; // Save the new round number
    }
  }

  function updatePointAndRound(uint256 _clanID, address _memberAddress) public { 
    checkAndUpdateRound();

    Clan storage clan = clans[_clanID];
    
    // Update clan point
    uint256 index = roundNumber;
    while (clan.point[index] == 0 && index > clan.info.firstRound) { index--; }
    clan.point[roundNumber] = clan.point[index];

    // Update total member point of the clan
    index = roundNumber;
    while (clan.totalMemberPoint[index] == 0 && index > clan.info.firstRound) { index--; }
    clan.totalMemberPoint[roundNumber] = clan.totalMemberPoint[index];
    
    // Member point of the clan
    if (_memberAddress == address(0)) { return; }  // If the member address is null, then skip it
    index = roundNumber;
    while (clan.member[_memberAddress].point[index] == 0 && index > clan.info.firstRound) { index--; }
    clan.member[_memberAddress].point[roundNumber] = clan.member[_memberAddress].point[index];
  }

  // Governance Functions
  function setMemberInfo(uint256 _clanID, address _address, bool _isMember) public {
    Clan storage clan = clans[_clanID];
    MemberInfo storage member = clan.member[_address];

    require(!clan.info.isDisbanded, "This clan is disbanded!");
    require(clan.member[_msgSender()].isMod, "You have no authority to moderate memberships for this clan!");
    require(clan.info.leader != _address, "You can't change the membership status of the leader!");

    if (_isMember) {
      require(!member.isMember, "The address is already a member!");
      require(_clanID == declaredClan[_address], "The address you wish to set as member should declare its clan first!");
      clan.members.push(_msgSender());
      clan.memberCounter.increment();
      clan.maxMemberCount++;
      member.isMember = true;
    }
    else if (member.isMember) { 
      member.isMember = false; 
      clan.memberCounter.decrement();
      // Keeps the member ID with it
    }
  }

  function setClanExecutor(uint256 _clanID, address _address, bool _isExecutor) public  {
    Clan storage clan = clans[_clanID];
    MemberInfo storage member = clans[_clanID].member[_address];

    require(!clan.info.isDisbanded, "This clan is disbanded!");
    require(_msgSender() == clan.info.leader, "You have no authority to give Executor Role for this clan!");

    if (_isExecutor) { member.isExecutor = true; }
    else { member.isExecutor = false; }
  }

  function setClanMod(uint256 _clanID, address _address, bool _isMod) public  {
    Clan storage clan = clans[_clanID];
    MemberInfo storage member = clans[_clanID].member[_address];

    require(!clan.info.isDisbanded, "This clan is disbanded!");
    require(_msgSender() == clan.info.leader, "You have no authority to give Executor Role for this clan!");

    if (_isMod) { member.isMod = true; }
    else { member.isMod = false; }
  }

  function giveMemberPoint(uint256 _clanID, address _memberAddress, uint256 _point, bool _isDecreasing) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    MemberInfo storage member = clans[_clanID].member[_memberAddress];

    require(!clan.info.isDisbanded, "This clan is disbanded!");
    require(clan.member[_msgSender()].isExecutor, "You have no authority to give point for this clan!");
    require(clan.member[_memberAddress].isMember, "The address is not a member!");
    
    // Update clan and round point before interact with them.
    updatePointAndRound(_clanID, _memberAddress);  

    // Update member point and total member point of the clan
    if (_isDecreasing) {
      member.point[roundNumber] -= _point;
      clan.totalMemberPoint[roundNumber] -= _point;
    }
    else {
      member.point[roundNumber] += _point;
      clan.totalMemberPoint[roundNumber] += _point;
    }
  }

  function giveBatchMemberPoint(uint256 _clanID, address[] memory _memberAddresses, uint256[] memory _points, bool[] memory _isDecreasing) public nonReentrant() {
    Clan storage clan = clans[_clanID];

    require(!clan.info.isDisbanded, "This clan is disbanded!");
    require(clan.member[_msgSender()].isExecutor, "You have no authority to give point for this clan!");
    require(_memberAddresses.length == _points.length, "Invalid input! Check array sizes!");
    require(_memberAddresses.length == _isDecreasing.length, "Invalid input! Check array sizes!");
    
    for(uint256 i = 0; i < _memberAddresses.length; i++) {      
      MemberInfo storage member = clans[_clanID].member[_memberAddresses[i]];

      require(clan.member[_memberAddresses[i]].isMember, "The address is not a member!");
      
      // Update clan and round point before interact with them.
      updatePointAndRound(_clanID, _memberAddresses[i]);  

      // Update member point and total member point of the clan
      if (_isDecreasing[i]) {
        member.point[roundNumber] -= _points[i];
        clan.totalMemberPoint[roundNumber] -= _points[i];
      }
      else {
        member.point[roundNumber] += _points[i];
        clan.totalMemberPoint[roundNumber] += _points[i];
      }
    }
  }

  function signalRebellion(uint256 _clanID) public {
    Clan storage clan = clans[_clanID];

    require(!clan.info.isDisbanded, "This clan is disbanded!");    
    require(clan.member[_msgSender()].isExecutor, "You have no authority to signal a rebellion for this clan!");

    // Signal a rebellion,
    ILord(contracts[7]).signalRebellion(clan.info.lordID, _clanID);
  }

  function transferLeadership(uint256 _clanID, address _newLeader) public  {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to transfer leadership for this clan!");
    clans[_clanID].info.leader = _newLeader;
  }

  function disbandClan(uint256 _clanID) public {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to disband this clan!");
    clans[_clanID].info.leader = address(0);    
    clans[_clanID].info.isDisbanded = true;
  }

  // Update Clan Info
  function updateClanName(uint256 _clanID, string memory _newName) public  {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].info.name = _newName;
  }
  
  function updateClanDescription(uint256 _clanID, string memory _newDescription) public  {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].info.description = _newDescription;
  }
  
  function updateClanMotto(uint256 _clanID, string memory _newMotto) public  {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].info.motto = _newMotto;
  }
  
  function updateClanLogoURI(uint256 _clanID, string memory _newLogoURI) public  {
    require(clans[_clanID].info.leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].info.logoURI = _newLogoURI;
  }

  /**
    Updates by DAO - Update Codes
    
    Contract Address Change -> Code: 1
    Proposal Type Change -> Code: 2
    maxPointToChange -> Code: 3
    cooldownTime -> Code: 4
    Min Balance to Clan Point Change -> Code: 5
    clan Point Adjustment -> Code: 6
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be null or the same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
      Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
    )); 

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[0]);

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
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if approved, apply the update the state
    if (proposal.status == Status.Approved)
      contracts[proposal.index] = proposal.newAddress;

    proposal.isExecuted = true;
  }

  function proposeFunctionsProposalTypesUpdate(uint256 _functionIndex, uint256 _newIndex) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");
    require(_newIndex != functionsProposalTypes[_functionIndex], "Desired function index is already set!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating proposal types of index ", Strings.toHexString(_functionIndex), " to ", 
      Strings.toHexString(_newIndex), " from ", Strings.toHexString(functionsProposalTypes[_functionIndex]), "."
    )); 

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[1]);

    // Get data to the proposal
    proposals[propID].updateCode = 2;
    proposals[propID].index = _functionIndex;
    proposals[propID].newUint = _newIndex;
  }

  function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");

    // Get its result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Wait for the current one to finalize
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if the current one is approved, apply the update the state
    if (proposal.status == Status.Approved)
      functionsProposalTypes[proposal.index] = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeMaxPointToChangeUpdate(uint256 _newMaxPoint) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating maximum clan point to change at a time to ",
      Strings.toHexString(_newMaxPoint), " from ", Strings.toHexString(maxPointToChange), "."
    )); 

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[2]);

    // Save data to the local proposal
    proposals[propID].updateCode = 3;
    proposals[propID].newUint = _newMaxPoint;
  }

  function executeMaxPointToChangeUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 3 && !proposal.isExecuted, "Wrong proposal ID");

    // Get the proposal result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Check if it is finalized or not
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved)
      maxPointToChange = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeCooldownTimeUpdate(uint256 _newCooldownTime) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating cooldown time (Unix Time) to ",
      Strings.toHexString(_newCooldownTime), " from ", Strings.toHexString(cooldownTime), "."
    )); 

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[3]);

    // Save data to the local proposal
    proposals[propID].updateCode = 4;
    proposals[propID].newUint = _newCooldownTime;
  }

  function executeCooldownTimeUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 4 && !proposal.isExecuted, "Wrong proposal ID");

    // Get the proposal result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Check if it is finalized or not
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved)
      cooldownTime = proposal.newUint;

    proposal.isExecuted = true;
  }  

  function proposeMinBalanceToPropClanPointUpdate(uint256 _newAmount) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating Minimum Balance To Propose to ", 
      Strings.toHexString(_newAmount), " from ", Strings.toHexString(minBalanceToProposeClanPointChange), "."
    )); 

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[4]);

    // Save data to the local proposal
    proposals[propID].updateCode = 5;
    proposals[propID].newUint = _newAmount;
  }

  function executeMinBalanceToPropClanPointUpdateProposal(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 5 && !proposal.isExecuted, "Wrong proposal ID");
    
    // Save the staus
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Check if it is finalized or not
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");

    // if the proposal is approved, apply the update the state
    if (proposal.status == Status.Approved)
      minBalanceToProposeClanPointChange = proposal.newUint;

    proposal.isExecuted = true;
  }

  /**
    @notice Anyone can propose point adjustmen right after the round is complete and until the next round.
    You can't propose a new proposal until the current proposal gets executed
   */ 
  function proposeClanPointAdjustment(uint256 _roundNumber, uint256 _clanID, uint256 _pointToChange, bool _isDecreasing) public {
    require(_pointToChange <= maxPointToChange, "Maximum amount of point exceeded!");
    require(!clans[_clanID].info.isDisbanded, "This clan is disbanded!");
    require(IDAO(contracts[4]).balanceOf(_msgSender()) >= minBalanceToProposeClanPointChange,
      "You don't have enough SDAO balance to make this proposal!"
    );

    // If the are in the new round
    checkAndUpdateRound();

    Clan storage clan = clans[_clanID];

    // After end of the round but until the end of the second round TEST: Check the numbers      Eg. RN:5, Allowed:4-3, Too late:2
    require(_roundNumber < roundNumber && _roundNumber > roundNumber - 2,
      "Invalid round number! You can make this proposal right after the round you want to complain about!"
    );

    // Wait for the proposal to finish or execute it.
    require(proposals[clan.proposal_ID].isExecuted, "Current proposal is not executed yet!");

    // PROPOSE
    string memory proposalDescription;
    if (!_isDecreasing){
      proposalDescription = string(abi.encodePacked(
        "In Clan contract, adding ", Strings.toHexString(_pointToChange), 
        " point to the clan ID: ", Strings.toHexString(_clanID), "." 
      )); 
    }
    else {
      proposalDescription = string(abi.encodePacked(
        "In Clan contract, subtracting ", Strings.toHexString(_pointToChange), 
        " point from the clan ID: ", Strings.toHexString(_clanID), "." 
      )); 
    }

    // Create a new proposal
    uint256 propID = IDAO(contracts[4]).newProposal(proposalDescription, functionsProposalTypes[5]);

    // Save data to the proposal
    proposals[propID].updateCode = 6;
    proposals[propID].index = _clanID;
    proposals[propID].newUint = _pointToChange;
    proposals[propID].newBool = _isDecreasing;

    // Save the proposal ID to the clan as well
    clan.proposal_ID = propID;
  }

  /**
    @dev Only the Stick DAO can clan point change AFTER the current round UP TO 2 round later. 
    DAO will need 2-3 days to get approved clan point change execution. Therefore, there are limited times to do so.
  */
  function executeClanPointAdjustment(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 6 && !proposal.isExecuted, "Wrong proposal ID");
    
    // Get the result from DAO
    proposal.status = Status(IDAO(contracts[4]).proposalResult(_proposalID));

    // Wait for the current one to finalize
    require(proposal.status > Status.OnGoing, "The proposal still going on or not even started!");
    
    Clan storage clan = clans[proposal.index]; // Proposal index is the Clan ID

    // Update clan point before interact with them. Not member (0)
    updatePointAndRound(proposal.index, address(0));


    // if approved, apply the update the state
    if (proposal.status == Status.Approved){
      // If the porposal bool (isDecreasing) is true, then subtract the point
      if (proposal.newBool){
        clan.point[roundNumber] -= proposal.newUint;
        rounds[roundNumber].totalClanPoint -= proposal.newUint;
      }
      else {
        clan.point[roundNumber] += proposal.newUint;
        rounds[roundNumber].totalClanPoint += proposal.newUint;
      }
    } 
  }
}