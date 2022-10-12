// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
/**
  * -> Update: DAO and Executer add, UpdatePropType, points for levels, Clan tax for members, country Code
  */

/*
 * @author Bora
 */

/**
  * @notice:
  * -> By default, everyone is a member of every clan. An address is an actual member if and only if 
  * the member has at least 1 point in the clan. Therefore, clan leaders or executers should give at 
  * least 1 point to all members to indicate them as members. Setting a member's points to 0 means 
  * kicking it out of the clan. 
  *
  * -> Only the leader can update clan name, description, motto, and logo.
  */

/**
  * Signalling rebellion - waits lord contract
  * Clans gets their rewards for the last seance - Waits the fukcingToken contract
  **/

contract FukcingClan is Context, ReentrancyGuard {
  using Counters for Counters.Counter;

  struct ClanMember {
    bool isExecutor;
    uint256 currentPoints;
    mapping(uint256 => uint256) pointsSnapshots;   // snapshot ID => the last point recorded
  }

  struct Clan {
    // Clan foundation info
    address leader;
    uint256 lordID;

    // Clan display info
    string name;
    string description;
    string motto;
    string logoURI;

    // Clan points and balance
    uint256 balance;    
    uint256 currentPoints;
    uint256 currentTotalMemberPoints;
    mapping(address => ClanMember) members;
    uint256 firstSnap;

    // Snapshots | Snap number => value
    mapping(uint256 => uint256) clanPointsSnapshots;   // Keep clan points for clan to claim
    mapping(uint256 => uint256) clanRewardSnapshots;  // Keep reward for memebers to claim
    mapping(uint256 => uint256) totalMemberPointsSnapshots; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Snapshot Number => Address => isclaimed?
    mapping(uint256 => uint256) claimedRewards;   // Total claimed rewards by members in a snap

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoints;
    bool isDisbanded;
  } 

  mapping(uint256 => Clan) public clans;      // Clan ID => Clan info
  mapping(address => uint256) public clanOf;  // ID of the clan of an address

  Counters.Counter public clanCounter;
  Counters.Counter public snapshotCounter;
  
  address public fukcingExecutors;
  address public fukcingClanLicence;
  address public fukcingLord;
  address public fukcingToken;
                                                                // Snapshot ID => Value
  mapping(uint256 => uint256) public totalClanPointsSnapshots;  // Total clan pts at the time
  mapping(uint256 => uint256) public clanRewards;               // Total clan reward at the time
  mapping(uint256 => uint256) public claimedRewards;            // Total claimd reward at the time
  mapping(uint256 => mapping(uint256 => bool)) public isClanClaimed; // snapshot Number => Clan ID => is claimed?

  uint256 public currentTotalClanPoints;
  uint256 public maxPointsToChange;               // Maximum point that can be given in a propsal
  uint256 public firstSeanceEnd;   // End of the first seance, hence the first reward time

  constructor(){
    clanCounter.increment();  // clan ID's should start from 
  }

  function createClan(
    uint256 _lordID, 
    string memory _clanName, 
    string memory _clanDescription, 
    string memory _clanMotto, 
    string memory _clanLogoURI
  ) 
  public nonReentrant() {
    // Burn licence to create a clan | lord ID = licence ID
    // If caller can burn it, then the clan will be attached to the lord with same ID
    ERC1155Burnable(fukcingClanLicence).burn(_msgSender() ,_lordID , 1);

    uint256 clanID = clanCounter.current();

    // Register the clan to the lord
    bytes memory payload = abi.encodeWithSignature("clanRegistration(uint256,uint256)", _lordID, clanID);
    (bool txSuccess, ) = address(fukcingLord).call(payload);
    require(txSuccess, "Transaction has fail to register clan to the Fukcing Lord contract!");

    // Create the clan
    Clan storage clan = clans[clanID];
    clanCounter.increment();

    clan.leader = _msgSender();
    clan.lordID = _lordID;
    clan.name = _clanName;
    clan.description = _clanDescription;
    clan.motto = _clanMotto;
    clan.logoURI = _clanLogoURI;
  }

  function joinToClan(uint256 _clanID) public {
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    address sender = _msgSender();
    uint256 currSnap = snapshotCounter.current();
    Clan storage currClan = clans[clanOf[sender]];

    // Erase data from the current clan
    currClan.totalMemberPointsSnapshots[currSnap] -= currClan.members[sender].currentPoints;
    currClan.members[sender].pointsSnapshots[currSnap] = 0;
    currClan.members[sender].currentPoints = 0;
    currClan.members[sender].isExecutor = false;

    // Keep record of the new clan ID of the address
    // Note: By default, everyone a member of all clans. Being a true member requires at least 1 point.
    clanOf[sender] = _clanID; 
  }

  function increaseClanPoints(uint256 _clanID, uint256 _points) public { // Test only executor can 
    require(_points <= maxPointsToChange, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    uint256 currSnap = snapshotCounter.current();
    Clan storage clan = clans[_clanID];

    // If the current snapshot 0, that indicates a new snapshot and we need to update it. 
    if (clans[_clanID].clanPointsSnapshots[currSnap] == 0)
      clan.clanPointsSnapshots[currSnap] = clan.currentPoints;
    
    // Give points to clan
    clan.clanPointsSnapshots[currSnap] += _points;
    clan.currentPoints += _points;

    // Update the total points of all clans
    totalClanPointsSnapshots[currSnap] += _points;
    currentTotalClanPoints += _points;

    // If this was the first time of this clan, record the first snap
    if (clan.firstSnap == 0) { clan.firstSnap = currSnap; }
  }

  function decreaseClanPoints(uint256 _clanID, uint256 _points) public { // Test only executor can and needs DAO approval !!!
    require(_points <= maxPointsToChange, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    uint256 currSnap = snapshotCounter.current();

    // If the current snapshot 0, that indicates a new snapshot and we need to update it. 
    if (clans[_clanID].clanPointsSnapshots[currSnap] == 0)
      clans[_clanID].clanPointsSnapshots[currSnap] = clans[_clanID].currentPoints;
    
    clans[_clanID].clanPointsSnapshots[currSnap] -= _points;
    clans[_clanID].currentPoints -= _points;

    totalClanPointsSnapshots[currSnap] -= _points;
    currentTotalClanPoints -= _points;
  }

  function clanRewardClaim(uint256 _clanID, uint256 _snapshotNumber) public {    
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");

    uint256 currSnap = snapshotCounter.current();
    // If time is up AND current snap hasn't received any rewards yet, get rewards from FukcingToken contract first
    if ((block.timestamp > (currSnap * 1 days) + firstSeanceEnd) && clanRewards[currSnap] == 0){ // TEST -> make it 7 days
      // Get the reward
      // Waiting for FukcingToken Contract to be complete
      clanRewards[currSnap] = 5; // TEST Change it to reward from FUKC
      
      // Pass on to the next snapshot
      snapshotCounter.increment();
      totalClanPointsSnapshots[snapshotCounter.current()] = currentTotalClanPoints;
    }

    uint256 _snap = _snapshotNumber;
    require(_snap < currSnap, "You can't claim the current or future seances' snaps. Check snapshot number!");

    require(isClanClaimed[_snap][_clanID] == false, "Your clan already claimed its reward for this snapshot!");
    isClanClaimed[_snap][_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // Update Current Clan points
    if (clan.clanPointsSnapshots[currSnap] == 0) {
      clan.clanPointsSnapshots[currSnap] = clan.currentPoints; 
      clan.totalMemberPointsSnapshots[currSnap] = clan.currentTotalMemberPoints;           
    }

    // Update clan points of desired snapshot ID as well
    uint256 index = _snap;
    while (clan.clanPointsSnapshots[index] == 0 && index > clan.firstSnap) { index--; }
    clan.clanPointsSnapshots[_snap] = clan.clanPointsSnapshots[index];

    // total clan reward * clan Points * 100 / total clan points
    uint256 reward = clanRewards[_snap] * (clan.clanPointsSnapshots[_snap] * 100 / totalClanPointsSnapshots[_snap]);
    claimedRewards[_snap] += reward;  // Keep record of the claimed rewards

    // Get the address and the tax rate of the lord
    (bool txSuccess, bytes memory returnData) = address(fukcingLord).call(abi.encodeWithSignature("lordTaxInfo(uint256)", clan.lordID));
    require(txSuccess, "Failed to get the address of the lord!");
    (address lordAddress, uint256 taxRate) = abi.decode(returnData, (address, uint256));

    // Then transfer the taxes
    IERC20(fukcingToken).transfer(lordAddress, reward * taxRate / 100);
    // Then keep the remaining for the clan
    clan.clanRewardSnapshots[_snap] = reward * (100 - taxRate) / 100;
    clan.balance += reward * (100 - taxRate) / 100;
  }

  function memberRewardClaim(uint256 _clanID, uint256 _snapshotNumber) public {
    Clan storage clan = clans[_clanID];
    uint256 _snap = _snapshotNumber;
    uint256 currSnap = snapshotCounter.current();
    address sender = _msgSender();
    
    require(_snap < currSnap, "You can't claim the current or future seances' snaps. Check snapshot number!");
    require(clan.isMemberClaimed[_snap][sender] == false, "You already claimed your reward for this snapshot!");
    clan.isMemberClaimed[_snap][sender] == true;  // If not claimed yet, mark it claimed.

    // Update the clan point if we are in a new seance. (Zero snap value indicates a new snap or non-member)
    if (clan.members[sender].pointsSnapshots[currSnap] == 0) {
      clan.members[sender].pointsSnapshots[currSnap] = clan.members[sender].currentPoints;      
      clan.totalMemberPointsSnapshots[currSnap] = clan.currentTotalMemberPoints;      
    }

    // Update member points of desired snapshot ID as well
    uint256 index = _snap;
    while (clan.members[sender].pointsSnapshots[index] == 0 && index > clan.firstSnap) { index--; }
    clan.members[sender].pointsSnapshots[_snap] = clan.members[sender].pointsSnapshots[index];

    // Update Total member points of desired snapshot ID as well
    index = _snap;
    while (clan.totalMemberPointsSnapshots[index] == 0 && index > clan.firstSnap) { index--; }
    clan.totalMemberPointsSnapshots[_snap] = clan.totalMemberPointsSnapshots[index];

    // if clan reward is not claimed by clan executors or the leader, claim it.
    if (clan.clanRewardSnapshots[_snap] == 0) { clanRewardClaim(_clanID, _snap); }      

    // calculate the reward and send it to the member!
    uint256 reward = // total reward of the clan * member Points * 100 / total member points of the clan
      clan.clanRewardSnapshots[_snap] * (clan.members[sender].pointsSnapshots[_snap] * 100 / clan.totalMemberPointsSnapshots[_snap]);

    IERC20(fukcingToken).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
    clan.claimedRewards[_snap] += reward; // Update the claimed rewards
  }

  // Governance Functions
  function setPoints(uint256 _clanID, address _memberAddress, uint256 _points) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_memberAddress];
    address sender = _msgSender();
    uint256 currSnap = snapshotCounter.current();

    require(clan.isDisbanded == false, "This clan is disbanded!");

    if (clan.canExecutorsSetPoints)
      require(clan.leader == sender || clan.members[sender].isExecutor, "You have no authority to set points for this clan!");
    else
      require(clan.leader == sender, "You have no authority to set points for this clan!");


    // Update the clan point if we are in a new seance. (Zero snap value indicates a new snap or non-member)
    if (clan.members[sender].pointsSnapshots[currSnap] == 0) {
      clan.members[sender].pointsSnapshots[currSnap] = clan.members[sender].currentPoints;      
      clan.totalMemberPointsSnapshots[currSnap] = clan.currentTotalMemberPoints;      
    }

    require(member.pointsSnapshots[currSnap] != _points, "The member has the exact points already!");

    // Update total member points of the clan
    if (_points > member.pointsSnapshots[currSnap])     
      clan.totalMemberPointsSnapshots[currSnap] += _points - member.pointsSnapshots[currSnap];
    else      
      clan.totalMemberPointsSnapshots[currSnap] -= member.pointsSnapshots[currSnap] - _points; 
    
    // Save the current points
    member.currentPoints = _points;
    member.pointsSnapshots[currSnap] = _points;
  }

  function setExecutor(uint256 _clanID, address _address, bool _isExecutor) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to set a rank for this clan!");
    clans[_clanID].members[_address].isExecutor = _isExecutor;
  }

  function transferLeadership(uint256 _clanID, address _newLeader) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to transfer leadership for this clan!");
    clans[_clanID].leader = _newLeader;
  }

  function disbandClan(uint256 _clanID) public {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to disband this clan!");
    clans[_clanID].leader = address(0);    
    clans[_clanID].isDisbanded = true;
  }

  function signalRebellion(uint256 _clanID) public {
    Clan storage clan = clans[_clanID];
    require(clan.isDisbanded == false, "This clan is disbanded!");
    
    if (clan.canExecutorsSignalRebellion){
      require(clan.leader == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to signal a rebellion for this clan!"
      );
    }
    else{      
      require(clan.leader == _msgSender(), "You have no authority to signal a rebellion for this clan!");
    }

    // Signal a rebellion,, waits lord contract
  }

  // Update Clan Info
  function updateClanName(uint256 _clanID, string memory _newName) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].name = _newName;
  }
  
  function updateClanDescription(uint256 _clanID, string memory _newDescription) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].description = _newDescription;
  }
  
  function updateClanMotto(uint256 _clanID, string memory _newMotto) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].motto = _newMotto;
  }
  
  function updateClanLogoURI(uint256 _clanID, string memory _newLogoURI) public  {
    require(clans[_clanID].leader == _msgSender(), "You have no authority to update clan name for this clan!");
    clans[_clanID].logoURI = _newLogoURI;
  }
  
  // Returns the real clan of an address. Only members with points are real members, others are default
  function getClan(address _address) public view returns (uint256) {
    return clans[clanOf[_address]].members[_address].currentPoints > 0 ? clanOf[_address] : 0;
  }

  // Returns true if the member is an executor in its clan
  function isMemberExecutor(address _memberAddress) public view returns (bool) {
    return clans[clanOf[_memberAddress]].members[_memberAddress].isExecutor;
  }

  // Returns the member's points
  function getMemberPoints(address _memberAddress) public view returns (uint256) {
    return clans[clanOf[_memberAddress]].members[_memberAddress].currentPoints;
  }
}