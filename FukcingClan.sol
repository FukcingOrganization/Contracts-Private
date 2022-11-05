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
  *
  * -> By default, everyone is a member of every clan. An address is an actual member if and only if 
  * the member has at least 1 point in the clan. Therefore, clan leaders or executers should give at 
  * least 1 point to all members to indicate them as members. Setting a member's points to 0 means 
  * kicking it out of the clan. 
  *
  * -> Only the leader can update clan name, description, motto, and logo.
  *
  * -> Clan leader can set any member as an executer to set members points and signal rebellion.
  * This will help clan leaders to reach large number of members.
  *
  * -> When we enter a new seance timeline, first clan that claims the reward triggers the seance.
  *
  * -> Clan leaders sets the members points and all members gets their clan reward based on their
  * member points compared to total member points.
  *
  * -> Executers and Fukcing DAO increases or decreases the points of clans. Executers doesn't need a
  * DAO approval to increase or decrease points of a clan. If DAO considers there has been a violation
  * of rights, DAO can start an proposal to take action. Executers and DAO have a maxiumum limit to change
  * points of a clan. DAO will have 3 days long proposal to make changes and Executers will have 6 days
  * cool down to make changes.
  *
  * -> Total clan rewards is limited by total supply of FDAO tokens. This incentivizes the DAO members
  * who are most likely the clans members to approve new FDAO token mints to expand DAO's member base and
  * increases decentralization of DAO.
  *
  * -> Executers can propose to update contract addresses, proposal types, cooldown time, and maximum 
  * point to change at a time.
  */

/**
  * @author Bora
  */
contract FukcingClan is Context, ReentrancyGuard {
  using Counters for Counters.Counter;

  struct ClanMember {
    bool isMember;
    bool isExecuter;
    bool isMod;
    mapping(uint256 => uint256) points;   // Seance Number => the last point recorded
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
    mapping(address => ClanMember) members;
    uint256 firstSeance;

    uint256 proposal_ID;

    // Seance Number => value
    mapping(uint256 => uint256) points;   // Keep clan points for clan to claim
    mapping(uint256 => uint256) rewards;  // Keep reward for members to claim
    mapping(uint256 => uint256) totalMemberPoints; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Seance Number => Address => isclaimed?
    mapping(uint256 => uint256) claimedRewards;     // Total claimed rewards by members in a seance

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoints;
    bool canModerateMembers;
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

  struct Seance {
    uint256 totalClanPoints;                // Total clan pts at the time
    uint256 clanRewards;                    // Total clan reward at the time
    uint256 claimedRewards;                 // Total claimd reward at the time
    mapping(uint256 => bool) isClanClaimed; // Clan ID => is claimed?
  }
  
  Counters.Counter public clanCounter;
  Counters.Counter public seanceCounter;

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
  mapping(uint256 => Seance) public seances;      // Proposal Number => Seance
  mapping(uint256 => Clan) public clans;          // Clan ID => Clan info
  mapping(address => uint256) public clanOf;      // ID of the clan of an address
  mapping(uint256 => uint256) public clanCooldownTime;  // Cooldown time for each clan | Clan ID => Cooldown time

  uint256 public maxPointsToChange;       // Maximum point that can be given in a propsal
  uint256 public cooldownTime;            // Cool down time to give clan points by executers
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

    // Sign the leader as a member of the clan as well and give full authority
    clan.members[_msgSender()].isMember = true;
    clan.members[_msgSender()].isExecuter = true;
    clan.members[_msgSender()].isMod = true;
  }

  function joinToClan(uint256 _clanID) public {
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");
    
    updateSeance();

    address sender = _msgSender();
    uint256 currSeance = seanceCounter.current();
    Clan storage currClan = clans[clanOf[sender]];

    // Erase data from the current clan
    currClan.members[sender].points[currSeance] = 0;
    currClan.members[sender].isMember = false;
    currClan.members[sender].isExecuter = false;
    currClan.members[sender].isMod = false;

    // Keep record of the new clan ID of the address
    // Note: By default, everyone a member of all clans. Being a true member requires at least 1 point.
    clanOf[sender] = _clanID; 
  }

  /**
    @dev Only the fukcing executers can give clan point. 
    There is a cooldown time to avoid executers change clan point as they wish.
    Executers can give clan point on for the current seance.
  */
  function giveClanPoints(uint256 _clanID, uint256 _points, bool _isDecreasing) public {
    require(_msgSender() == contracts[5], "Only Fukcing Executers can call this fukcing function!"); 
    require(_points <= maxPointsToChange, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");
    
    // Wait if the cooldown time is not passed. Avoids executers to change points as they wish!
    require(block.timestamp > clanCooldownTime[_clanID], "Wait for the cooldown time!");
    clanCooldownTime[_clanID] = block.timestamp + cooldownTime; // set a new cooldown time

    // If the are in the new seance
    updateSeance();

    uint256 currSeance = seanceCounter.current();
    Clan storage clan = clans[_clanID];

    // Update clan points before interact with them. Not member (0)
    updatePoints(_clanID, address(0));
    
    if (_isDecreasing){
      clan.points[currSeance] -= _points;
      seances[currSeance].totalClanPoints -= _points;
    }
    else {
      clan.points[currSeance] += _points;
      seances[currSeance].totalClanPoints += _points;
    }

    // If this was the first time of this clan, record the first seance
    if (clan.firstSeance == 0) { clan.firstSeance = currSeance; }
  }

  function clanRewardClaim(uint256 _clanID, uint256 _seanceNumber) public {    
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");

    // If the are in the new seance
    updateSeance();

    uint256 currSeance = seanceCounter.current();

    uint256 _seance = _seanceNumber;
    require(_seance < currSeance, "You can't claim the current or future seances' seances. Check seance number!");

    require(seances[currSeance].isClanClaimed[_clanID] == false, "Your clan already claimed its reward for this seance!");
    seances[currSeance].isClanClaimed[_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // Update clan points before interact with them. Not member (0)
    updatePoints(_clanID, address(0));  

    // total clan reward * clan Points * 100 / total clan points
    uint256 reward = seances[currSeance].clanRewards * (clan.points[_seance] * 100 / seances[currSeance].totalClanPoints);
    seances[currSeance].claimedRewards += reward;  // Keep record of the claimed rewards

    // Get the address and the tax rate of the lord
    (bool txSuccess1, bytes memory returnData1) = address(contracts[7]).call(abi.encodeWithSignature("lordTaxInfo(uint256)", clan.lordID));
    require(txSuccess1, "Failed to get the address of the lord!");
    (address lordAddress, uint256 taxRate) = abi.decode(returnData1, (address, uint256));

    // Get the lord tax and update the reward after tax
    uint256 lordTax = reward * taxRate / 100;
    reward -= lordTax;

    // Then transfer the taxes if there lord address exist. (which means lord is alive)
    if (lordAddress != address(0))
      IERC20(contracts[11]).transfer(lordAddress, lordTax);

    // Then keep the remaining for the clan
    clan.rewards[currSeance] = reward;
    clan.balance += reward;
  }

  function memberRewardClaim(uint256 _clanID, uint256 _seanceNumber) public {
    // If the are in the new seance
    updateSeance();

    Clan storage clan = clans[_clanID];
    uint256 _seance = _seanceNumber;
    uint256 currSeance = seanceCounter.current();
    address sender = _msgSender();
    
    require(clan.members[sender].isMember, "You are not a member of this clan!");
    require(3 <= currSeance, "Wait for the first 3 seance to finish to have finalized reward!");
    require(_seance <= currSeance - 3, "You can't claim the reward until it finalizes. Rewards are getting finalized after 3 seances!");
    require(clan.isMemberClaimed[_seance][sender] == false, "You already claimed your reward for this seance!");
    clan.isMemberClaimed[_seance][sender] == true;  // If not claimed yet, mark it claimed.

    // Update clan points before interact with them.
    updatePoints(_clanID, sender);  

    // if clan reward is not claimed by clan executors or the leader, claim it.
    if (clan.rewards[_seance] == 0) { clanRewardClaim(_clanID, _seance); }      

    // calculate the reward and send it to the member!
    uint256 reward = // total reward of the clan * member Points * 100 / total member points of the clan
      clan.rewards[_seance] * (clan.members[sender].points[_seance] * 100 / clan.totalMemberPoints[_seance]);

    IERC20(contracts[11]).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
    clan.claimedRewards[_seance] += reward; // Update the claimed rewards

    // Mint FDAO tokens as much as the clan member reward
    (bool txSuccess,) = contracts[4].call(abi.encodeWithSignature("mintTokens(address,uint256)", sender, reward));
    require(txSuccess, "Transaction failed to mint new FDAO tokens!");
  }

  /// @dev Starts the new seance if the time is up
  function updateSeance() public {
    uint256 currSeance = seanceCounter.current();

    // If time is up, get rewards from FukcingToken contract first
    if (block.timestamp > (currSeance * 1 days) + firstSeanceEnd){ // TEST -> make it 7 days
      // Get the clans rewards from fukcing token
      (bool txSuccess0, bytes memory returnData0) = contracts[11].call(abi.encodeWithSignature("clanMint()"));
      require(txSuccess0, "Transaction has failed to get backer rewards from Fukcing Token contract!");

      // Save the reward to the seance
      (seances[currSeance].clanRewards) = abi.decode(returnData0, (uint256));

      // Keep the total clan points to pass on to the next seance
      uint256 currentTotalClanPoints = seances[currSeance].totalClanPoints;

      // Pass on to the next seance
      seanceCounter.increment();

      // Pass on the current total clan points to the next seance
      seances[seanceCounter.current()].totalClanPoints = currentTotalClanPoints;
    }
  }

  function updatePoints(uint256 _clanID, address _member) internal {  
    uint256 currSeance = seanceCounter.current();
    Clan storage clan = clans[_clanID];
    
    // Update clan point
    uint256 index = currSeance;
    while (clan.points[index] == 0 && index > clan.firstSeance) { index--; }
    clan.points[currSeance] = clan.points[index];

    // Update total member points of the clan
    index = currSeance;
    while (clan.totalMemberPoints[index] == 0 && index > clan.firstSeance) { index--; }
    clan.totalMemberPoints[currSeance] = clan.totalMemberPoints[index];
    
    // Member point of the clan
    if (_member == address(0)) { return; }  // If the member address is null, then skip it
    index = currSeance;
    while (clan.members[_member].points[index] == 0 && index > clan.firstSeance) { index--; }
    clan.members[_member].points[currSeance] = clan.members[_member].points[index];
  }

  // Governance Functions
  function setClanMember(uint256 _clanID, address _address, bool _isMember) public {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_address];

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(clan.members[_msgSender()].isMod, "You have no authority to moderate memberships for this clan!");

    if (_isMember) { member.isMember = true; }
    else { member.isMember = false; }
  }

  function setClanExecuter(uint256 _clanID, address _address, bool _isExecuter) public  {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_address];

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(_msgSender() == clan.leader, "You have no authority to give Executer Role for this clan!");

    if (_isExecuter) { member.isExecuter = true; }
    else { member.isExecuter = false; }
  }

  function setClanMod(uint256 _clanID, address _address, bool _isMod) public  {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_address];

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(_msgSender() == clan.leader, "You have no authority to give Executer Role for this clan!");

    if (_isMod) { member.isMod = true; }
    else { member.isMod = false; }
  }

  function giveMemberPoints(uint256 _clanID, address _memberAddress, uint256 _points, bool _isDecreasing) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[_memberAddress];
    
    updateSeance();
    uint256 currSeance = seanceCounter.current();

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(clan.members[_msgSender()].isExecuter, "You have no authority to give points for this clan!");

    // Update clan points before interact with them.
    updatePoints(_clanID, _memberAddress);  

    // Update member points and total member points of the clan
    if (_isDecreasing) {
      member.points[currSeance] -= _points;
      clan.totalMemberPoints[currSeance] -= _points;
    }
    else {
      member.points[currSeance] += _points;
      clan.totalMemberPoints[currSeance] += _points;
    }
  }

  function signalRebellion(uint256 _clanID) public {
    Clan storage clan = clans[_clanID];

    require(clan.isDisbanded == false, "This clan is disbanded!");    
    require(clan.members[_msgSender()].isExecuter, "You have no authority to signal a rebellion for this clan!");

    // Signal a rebellion,
    (bool txSuccess, ) = contracts[7].call(abi.encodeWithSignature(
      "signalRebellion(uint256,uint256)", clan.lordID, _clanID)
    );
    require(txSuccess, "The transaction has failed when signalling");
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
    return clans[clanOf[_address]].members[_address].isMember ? clanOf[_address] : 0;
  }

  // Returns true if the member is an executor in its clan
  function isMemberExecutor(address _memberAddress) public view returns (bool) {
    return clans[clanOf[_memberAddress]].members[_memberAddress].isExecuter;
  }

  // Returns true if the member is an executor in its clan
  function isMemberMod(address _memberAddress) public view returns (bool) {
    return clans[clanOf[_memberAddress]].members[_memberAddress].isMod;
  }

  // Returns the member's points
  function getMemberPoints(address _memberAddress) public returns (uint256) {
    uint256 clanID = clanOf[_memberAddress];
    ClanMember storage member = clans[clanOf[_memberAddress]].members[_memberAddress];

    // Update clan points before interact with them.
    updateSeance();
    updatePoints(clanID, _memberAddress); 

    return member.points[seanceCounter.current()];
  }

  /**
   * Updates by DAO - Update Codes
   *
   * Contract Address Change -> Code: 1
   * Proposal Type Change -> Code: 2
   * maxPointsToChange -> Code: 3
   * cooldownTime -> Code: 4
   * clan Point Adjustment -> Code: 5
   * 
   */
  function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
    require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
    require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
      "New address can not be null or the same address!"
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

  /**
    @notice Anyone can propose point adjustmen right after the seance is complete and until the next seance.
    You can't propose a new proposal until the current proposal gets executed
   */ 
  function proposeClanPointAdjustment(uint256 _seanceNumber, uint256 _clanID, uint256 _pointsToChange, bool _isDecreasing) public {
    require(_pointsToChange <= maxPointsToChange, "Maximum amount of points exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    // If the are in the new seance
    updateSeance();

    uint256 currSeance = seanceCounter.current();
    Clan storage clan = clans[_clanID];

    // Clan leaders can make proposals after end of the seance but until the end of the second seance
    require(_seanceNumber == currSeance - 1, "Invalid seance number!");

    // Wait for the proposal to finish or execute it.
    require(proposals[clan.proposal_ID].isExecuted, "Current proposal is not executed yet!");

    // PROPOSE
    string memory proposalDescription;
    if (!_isDecreasing){
      proposalDescription = string(abi.encodePacked(
        "In Fukcing Clan contract, adding ", Strings.toHexString(_pointsToChange), 
        " points to the clan ID: ", Strings.toHexString(_clanID), "." 
      )); 
    }
    else {
      proposalDescription = string(abi.encodePacked(
        "In Fukcing Clan contract, subtracting ", Strings.toHexString(_pointsToChange), 
        " points from the clan ID: ", Strings.toHexString(_clanID), "." 
      )); 
    }

    // Create a new proposal - Call DAO contract (contracts[4]) - proposal type : 1 - Moderately Important
    (bool txSuccess, bytes memory returnData) = contracts[4].call(
      abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[1])
    );
    require(txSuccess, "Transaction failed to make new proposal!");

    // Save the ID to create proposal in here
    (uint256 propID) = abi.decode(returnData, (uint256));

    // Save data to the proposal
    proposals[propID].updateCode = 5;
    proposals[propID].index = _clanID;
    proposals[propID].newUint = _pointsToChange;
    proposals[propID].newBool = _isDecreasing;

    // Save the proposal ID to the clan as well
    clan.proposal_ID = propID;
  }

  /**
    @dev Only the fukcing DAO can clan point change AFTER the current seance UP TO 2 seance later. 
    DAO will need 2-3 days to get approved clan point change execution. Therefore, there are limited times to do so.
  */
  function executeClanPointAdjustment(uint256 _proposalID) public {
    Proposal storage proposal = proposals[_proposalID];

    require(proposal.updateCode == 5 && !proposal.isExecuted, "Wrong proposal ID");
    
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
    
    Clan storage clan = clans[proposal.index]; // Proposal index is the Clan ID

    // Check seance update
    updateSeance();
    uint256 currSeance = seanceCounter.current();

    // Update clan points before interact with them. Not member (0)
    updatePoints(proposal.index, address(0));


    // if approved, apply the update the state
    if (proposal.status == Status.Approved){
      // If the porposal bool (isDecreasing) is true, then subtract the points
      if (proposal.newBool){
        clan.points[currSeance] -= proposal.newUint;
        seances[currSeance].totalClanPoints -= proposal.newUint;
      }
      else {
        clan.points[currSeance] += proposal.newUint;
        seances[currSeance].totalClanPoints += proposal.newUint;
      }
    }

    // If this was the first time of this clan to get points, record the first seance
    if (clan.firstSeance == 0) { clan.firstSeance = currSeance; }    
  }
}