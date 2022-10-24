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
  * @notice
  * -> To create clan, you need a clan licence. When you create a clan, your clan licence burns.
  * -> By default, everyone is a member of every clan. An address is an actual member if and only if 
  * the member has at least 1 point in the clan. Therefore, clan leaders or executers should give at 
  * least 1 point to all members to indicate them as members. Setting a member's points to 0 means 
  * kicking it out of the clan. 
  * -> Only the leader can update clan name, description, motto, and logo.
  * -> Clan leader can set any member as an executer to set members points and signal rebellion.
  * This will help clan leaders to reach large number of members.
  * -> When we enter a new seance timeline, first clan that claims the reward triggers the snapshot.
  * -> Clan leaders sets the members points and all members gets their clan reward based on their
  * member points compared to total member points.
  * -> Executers and Fukcing DAO increases or decreases the points of clans. Executers doesn't need a
  * DAO approval to increase or decrease points of a clan. If DAO considers there has been a violation
  * of rights, DAO can start an proposal to take action. Executers and DAO have a maxiumum limit to change
  * points of a clan. DAO will have 3 days long proposal to make changes and Executers will have 6 days
  * cool down to make changes.
  * -> Total clan rewards is limited by total supply of FDAO tokens. This incentivizes the DAO members
  * who are most likely the clans members to approve new FDAO token mints to expand DAO's member base and
  * increases decentralization of DAO.
  * -> Executers can propose to update contract addresses, proposal types, cooldown time, and maximum 
  * point to change at a time.
  */

/**
  * @author Bora
  */
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
    mapping(uint256 => uint256) clanPointsSnapshots;  // Keep clan points for clan to claim
    mapping(uint256 => uint256) clanRewardSnapshots;  // Keep reward for memebers to claim
    mapping(uint256 => uint256) totalMemberPointsSnapshots; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Snapshot Number => Address => isclaimed?
    mapping(uint256 => uint256) claimedRewards;   // Total claimed rewards by members in a snap

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoints;
    bool isDisbanded;
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
   * Index 2: ClanLicence Contract        
   * Index 3: Community Contract         
   * Index 4: DAO Contract               
   * Index 5: Executor Contract            
   * Index 6: Items Contract            
   * Index 7: Lord Contract               
   * Index 8: Rent Contract               
   * Index 9: Seance Contract             
   * Index 10: Staking Contract           
   * Index 11: Token Contract          
   * Index 12: Developer Contract/address  
   */
  address[13] public contracts; 

  mapping(uint256 => Proposal) public proposals;  // Proposal ID => Proposal
  mapping(uint256 => Clan) public clans;          // Clan ID => Clan info
  mapping(address => uint256) public clanOf;      // ID of the clan of an address

  Counters.Counter public clanCounter;
  Counters.Counter public snapshotCounter;
                                                                      // Snapshot ID => Value
  mapping(uint256 => uint256) public totalClanPointsSnapshots;        // Total clan pts at the time
  mapping(uint256 => uint256) public clanRewards;                     // Total clan reward at the time
  mapping(uint256 => uint256) public claimedRewards;                  // Total claimd reward at the time
  mapping(uint256 => mapping(uint256 => bool)) public isClanClaimed;  // snapshot Number => Clan ID => is claimed?
  mapping(uint256 => uint256) public clanCooldownTime;                  // Total claimd reward at the time

  uint256 public currentTotalClanPoints;
  uint256 public maxPointsToChange;       // Maximum point that can be given in a propsal
  uint256 public cooldownTime;            // Maximum point that can be given in a propsal
  uint256 public firstSeanceEnd;          // End of the first seance, hence the first reward time

  constructor(){
    clanCounter.increment();  // clan ID's should start from 1
    maxPointsToChange = 666;
    cooldownTime = 3 days;
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
    ERC1155Burnable(contracts[1]).burn(_msgSender() ,_lordID , 1);

    uint256 clanID = clanCounter.current();

    // Register the clan to the lord
    bytes memory payload = abi.encodeWithSignature("clanRegistration(uint256,uint256)", _lordID, clanID);
    (bool txSuccess, ) = address(contracts[7]).call(payload);
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

  function giveClanPoints(uint256 _clanID, uint256 _points, bool _isDecreasing) public {
    require(_msgSender() == contracts[5] || _msgSender() == contracts[4], 
      "Only Executers or DAO can call this fukcing function!"
    ); 
    require(_points <= maxPointsToChange, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    // If executers making a change, check the cooldown
    if (_msgSender() == contracts[5]){
      require(block.timestamp > clanCooldownTime[_clanID], "Wait for the cooldown time!");
      clanCooldownTime[_clanID] = block.timestamp + cooldownTime; // set a new cooldown time
    }

    uint256 currSnap = snapshotCounter.current();
    Clan storage clan = clans[_clanID];

    // If the current snapshot 0, that indicates a new snapshot and we need to update it. 
    if (clans[_clanID].clanPointsSnapshots[currSnap] == 0)
      clan.clanPointsSnapshots[currSnap] = clan.currentPoints;
    
    if (_isDecreasing){
      // Give points to clan
      clan.clanPointsSnapshots[currSnap] -= _points;
      clan.currentPoints -= _points;

      // Update the total points of all clans
      totalClanPointsSnapshots[currSnap] -= _points;
      currentTotalClanPoints -= _points;
    }
    else {
      // Give points to clan
      clan.clanPointsSnapshots[currSnap] += _points;
      clan.currentPoints += _points;

      // Update the total points of all clans
      totalClanPointsSnapshots[currSnap] += _points;
      currentTotalClanPoints += _points;
    }

    // If this was the first time of this clan, record the first snap
    if (clan.firstSnap == 0) { clan.firstSnap = currSnap; }
  }

  function clanRewardClaim(uint256 _clanID, uint256 _snapshotNumber) public {    
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");

    uint256 currSnap = snapshotCounter.current();
    // If time is up AND current snap hasn't received any rewards yet, get rewards from FukcingToken contract first
    if ((block.timestamp > (currSnap * 1 days) + firstSeanceEnd) && clanRewards[currSnap] == 0){ // TEST -> make it 7 days
      // Get the clans rewards from fukcing token
      (bool txSuccess0, bytes memory returnData0) = contracts[11].call(abi.encodeWithSignature("clanMint()"));
      require(txSuccess0, "Transaction has failed to get backer rewards from Fukcing Token contract!");

      // Save it
      (clanRewards[currSnap]) = abi.decode(returnData0, (uint256));
      
      // Pass on to the next snapshot
      snapshotCounter.increment();
      totalClanPointsSnapshots[snapshotCounter.current()] = currentTotalClanPoints;
    }

    uint256 _snap = _snapshotNumber;
    require(_snap < currSnap, "You can't claim the current or future seances' snaps. Check snapshot number!");

    require(isClanClaimed[_snap][_clanID] == false, "Your clan already claimed its reward for this snapshot!");
    isClanClaimed[_snap][_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // Update Current Clan point snaps
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
    (bool txSuccess1, bytes memory returnData1) = address(contracts[7]).call(abi.encodeWithSignature("lordTaxInfo(uint256)", clan.lordID));
    require(txSuccess1, "Failed to get the address of the lord!");
    (address lordAddress, uint256 taxRate) = abi.decode(returnData1, (address, uint256));

    // Then transfer the taxes if there lord address exist. (which means lord is alive)
    if (lordAddress != address(0))
      IERC20(contracts[11]).transfer(lordAddress, reward * taxRate / 100);

    // Then keep the remaining for the clan
    uint256 clanRewardAfterTax = reward * (100 - taxRate) / 100;
    clan.clanRewardSnapshots[_snap] = clanRewardAfterTax;
    clan.balance += clanRewardAfterTax;
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

    IERC20(contracts[11]).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
    clan.claimedRewards[_snap] += reward; // Update the claimed rewards
  }

  // Governance Functions
  function setMemberPoints(uint256 _clanID, address _memberAddress, uint256 _points, bool _isDecreasing) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_memberAddress];
    uint256 currSnap = snapshotCounter.current();

    require(clan.isDisbanded == false, "This clan is disbanded!");

    if (clan.canExecutorsSetPoints){
      require(clan.leader == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to set points for this clan!"
      );
    }
    else{      
      require(clan.leader == _msgSender(), "You have no authority to set points for this clan!");
    }


    // Update the clan point if we are in a new seance. (Zero snap value indicates a new snap or non-member)
    if (member.pointsSnapshots[currSnap] == 0) {
      member.pointsSnapshots[currSnap] = member.currentPoints;      
      clan.totalMemberPointsSnapshots[currSnap] = clan.currentTotalMemberPoints;      
    }

    // Update member points and total member points of the clan
    if (_isDecreasing) {
      member.currentPoints -= _points;
      member.pointsSnapshots[currSnap] -= _points;
      clan.totalMemberPointsSnapshots[currSnap] -= _points;
    }
    else {
      member.currentPoints += _points;
      member.pointsSnapshots[currSnap] += _points;
      clan.totalMemberPointsSnapshots[currSnap] += _points;
    }
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

    // Signal a rebellion,
    (bool txSuccess, ) = contracts[7].call(abi.encodeWithSignature(
      "signalRebellion(uint256,uint256)", clan.lordID, _clanID)
    );
    require(txSuccess, "The transaction has failed when signalling");
  }

  function setClanExecutor(uint256 _clanID, address _address, bool _isExecutor) public  {
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

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * maxPointsToChange -> Code: 3
   * cooldownTime -> Code: 4
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be the null or same address!"
    );

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Clan contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
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
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
    require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Clan contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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

  function proposeMaxPointToChangeUpdate(uint256 _newMaxPoint) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Clan contract, updating maximum clan points to change at a time to ",
      Strings.toHexString(_newMaxPoint), " from ", Strings.toHexString(maxPointsToChange), "."
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
    proposals[propID].newUint = _newMaxPoint;
  }

  function executeMaxPointToChangeUpdateProposal(uint256 _proposalID) public {
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
      maxPointsToChange = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeCooldownTimeUpdate(uint256 _newCooldownTime) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Fukcing Clan contract, updating cooldown time (Unix Time) to ",
      Strings.toHexString(_newCooldownTime), " from ", Strings.toHexString(cooldownTime), "."
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
    proposals[propID].newUint = _newCooldownTime;
  }

  function executeCooldownTimeUpdateProposal(uint256 _proposalID) public {
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
      cooldownTime = proposal.newUint;

    proposal.isExecuted = true;
  }
}