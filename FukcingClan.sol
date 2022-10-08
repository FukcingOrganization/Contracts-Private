// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
  * -> Executers can add new points (DAO), ??? If we do it with DAO, we should do it with merkle roots and in bulk.
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
    mapping(uint256 => uint256) pointSnapshots;   // snapshot ID => the last point recorded
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
    uint256 points;

    // Members  informations
    mapping(address => ClanMember) members;

    // Snapshots
    mapping(uint256 => uint256) clanRewardSnapshots;  // Keep reward for memebers to claim
    mapping(uint256 => uint256) clanPointSnapshots;   // Keep clan points for clan to claim
    mapping(uint256 => uint256) totalMemberPointsSnapshots; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Snapshot Number => Address => isclaimed?

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoints;
    bool isDisbanded;
  } 

  mapping(uint256 => Clan) public clans;      // Clan ID => Clan info
  mapping(address => uint256) public clanOf;  // ID of the clan of an address

  Counters.Counter private clanCounter;
  Counters.Counter private snapshotCounter;
  
  address public fukcingExecutors;
  address public fukcingClanLicence;
  address public fukcingLord;
  address public fukcingToken;

  mapping(uint256 => uint256) totalClanPointsSnapshots; // Total clan pts at the time
  mapping(uint256 => uint256) rewardAtSnapshot;         // Total clan reward at the time
  mapping(uint256 => mapping(uint256 => bool)) isClanClaimed; // snapshot Number => Clan ID => is claimed?

  uint256 maxPoints;         // Maximum point that can be given in a propsal
  uint256 initialClanRewardTime;    // End of the first seance, hence the first reward time

  constructor(){
  }

  function createClan(
    uint256 _lordID, 
    string memory _clanName, 
    string memory _clanDescription, 
    string memory _clanMotto, 
    string memory _clanLogoURI
  ) 
  public nonReentrant() {
    // Burn licence to create a clan
    bytes memory payload = abi.encodeWithSignature("burn(address,uint256,uint256)", _msgSender(), _lordID, 1);
    (bool txSuccess, ) = address(fukcingClanLicence).call(payload);
    require(txSuccess, "Burn to mint tx has failed! Insufficient approval amount or ERC20 token is not burnable!");

    // Create the clan
    Clan storage clan = clans[clanCounter.current()];
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

    // Erase data from the previous clan
    ClanMember storage member = clans[_clanID].members[_msgSender()];
    uint256 snap = snapshotCounter.current();

    clans[_clanID].totalMemberPointsSnapshots[snap] -= member.pointSnapshots[snap];
    member.pointSnapshots[snap] = 0;
    member.isExecutor = false;

    // Join the new clan
    clanOf[_msgSender()] = _clanID;
  }

  function increaseClanPoints(uint256 _clanID, uint256 _points) public { // Test only executor can 
    require(_points <= maxPoints, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    clans[_clanID].points += _points;
    clans[_clanID].clanPointSnapshots[snapshotCounter.current()] = clans[_clanID].points;
    totalClanPointsSnapshots[snapshotCounter.current()] += _points;
  }

  function decreaseClanPoints(uint256 _clanID, uint256 _points) public { // Test only executor can and needs DAO approval !!!
    require(_points <= maxPoints, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    clans[_clanID].points -= _points;
    clans[_clanID].clanPointSnapshots[snapshotCounter.current()] = clans[_clanID].points;
    totalClanPointsSnapshots[snapshotCounter.current()] -= _points;
  }

  function clanRewardClaim(uint256 _clanID, uint256 _snapshotNumber) public {
    // If time is up, get rewards from FukcingToken contract first
    if (block.timestamp > (snapshotCounter.current() + 1) * initialClanRewardTime){
      // Get the reward
      // Waiting for FukcingToken Contract to be complete
      rewardAtSnapshot[snapshotCounter.current()] = 5; // TEST Change it to reward from FUKC
      
      // Take snapshot
      snapshotCounter.increment();
    }

    uint256 snap = _snapshotNumber;
    require(snap < snapshotCounter.current(), "You can't claim the current or future seances' snaps. Check snaphot number!");

    require(isClanClaimed[snap][_clanID] == false, "Your clan already claimed its reward for this snaphot!");
    isClanClaimed[snap][_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // total clan reward * clan Points * 100 / total clan points
    uint256 reward = rewardAtSnapshot[snap] * (clan.clanPointSnapshots[snap] * 100 / totalClanPointsSnapshots[snap]);

    // Get the address and the tax rate of the lord
    (bool txSuccess, bytes memory returnData) = address(fukcingLord).call(abi.encodeWithSignature("lordTaxInfo(uint256)", clan.lordID));
    require(txSuccess, "Failed to get the address of the lord!");
    (address lordAddress, uint256 taxRate) = abi.decode(returnData, (address, uint256));

    // Then transfer the taxes
    IERC20(fukcingToken).transfer(lordAddress, reward * taxRate / 100);
    // Then keep the remaining for the clan
    clan.clanRewardSnapshots[snap] = reward * (100 - taxRate) / 100;
    clan.balance += reward * (100 - taxRate) / 100;
  }

  function memberRewardClaim(uint256 _clanID, uint256 _snapshotNumber) public {
    Clan storage clan = clans[_clanID];
    uint256 snap = _snapshotNumber;
    address sender = _msgSender();
    
    require(snap < snapshotCounter.current(), "You can't claim the current or future seances' snaps. Check snaphot number!");
    require(clan.isMemberClaimed[snap][sender] == false, "You already claimed your reward for this snaphot!");
    clan.isMemberClaimed[snap][sender] == true;  // If not claimed yet, mark it claimed.

    // calculate the reward and send it to the member!
    uint256 reward = // total reward of the clan * member Points * 100 / total member points of the clan
      clan.clanRewardSnapshots[snap] * (clan.members[sender].pointSnapshots[snap] * 100 / clan.totalMemberPointsSnapshots[snap]);
    IERC20(fukcingToken).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
  }

  // Governance Functions
  function setPoints(uint256 _clanID, address _address, uint256 _points) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    require(clan.isDisbanded == false, "This clan is disbanded!");

    if (clan.canExecutorsSetPoints){
      require(clan.leader == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to set points for this clan!"
      );
    }
    else{      
      require(clan.leader == _msgSender(), "You have no authority to set points for this clan!");
    }

    ClanMember storage member = clans[_clanID].members[_address];
    uint256 snap = snapshotCounter.current();
    require(member.pointSnapshots[snap] != _points, "The member has the exact points already!");
    
    // Update total member points of the clan
    if (_points > member.pointSnapshots[snap])     
      clan.totalMemberPointsSnapshots[snap] += _points - member.pointSnapshots[snap];
    else      
      clan.totalMemberPointsSnapshots[snap] -= member.pointSnapshots[snap] - _points; 
    
    // Save the current points
    member.pointSnapshots[snap] = _points - member.pointSnapshots[snap];
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
    Clan storage clan = clans[_clanID];

    require(clan.leader == _msgSender(), "You have no authority to disband this clan!");

    clan.leader = address(0);
    clan.points = 0;
    clan.totalMemberPointsSnapshots[snapshotCounter.current()] = 0;
    
    clan.isDisbanded = true;
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
}