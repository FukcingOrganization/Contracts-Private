// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Burnable.sol";
import "./ERC1155Burnable.sol";
import "./IERC20.sol";
import "./Context.sol";
import "./ReentrancyGuard.sol";
import "./Counters.sol";
import "./Strings.sol";

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
  
  - Total clan rewards is limited by total supply of FDAO tokens. This incentivizes the DAO members
  who are most likely the clans members to approve new FDAO token mints to expand DAO's member base and
  increases decentralization of DAO.
  
  - Executors can propose to update contract addresses, proposal types, cooldown time, and maximum 
  point to change at a time.
  */

/// @author Bora
contract StickClan is Context, ReentrancyGuard {
  using Counters for Counters.Counter;

  struct ClanMember {
    uint256 memberID;
    address memberAddress;
    bool isMember;
    bool isExecutor;
    bool isMod;
    uint256 currentPoint;
    mapping(uint256 => uint256) point;   // Round Number => the last point recorded
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

    // Clan point and balance
    uint256 proposal_ID;
    uint256 currentPoint;
    uint256 currentTotalMemberPoint;
    uint256 firstRound;
    uint256 balance;        
    mapping(uint256 => ClanMember) members;
    mapping(address => uint256) memberIdOf;
    Counters.Counter memberCounter;
    uint256 lastMemberID;

    // Round Number => value
    mapping(uint256 => uint256) point;   // Keep clan point for clan to claim
    mapping(uint256 => uint256) rewards;  // Keep reward for members to claim
    mapping(uint256 => uint256) totalMemberPoint; // Total member pts at the time
    mapping(uint256 => mapping(address => bool)) isMemberClaimed; // Round Number => Address => isclaimed?
    mapping(uint256 => uint256) claimedRewards;     // Total claimed rewards by members in a round

    // Admin settings of the Clan set by the leader
    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoint;
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

  struct Round {
    uint256 totalClanPoint;                // Total clan pts at the time
    uint256 clanRewards;                    // Total clan reward at the time
    uint256 claimedRewards;                 // Total claimd reward at the time
    mapping(uint256 => bool) isClanClaimed; // Clan ID => is claimed?
  }
  
  Counters.Counter public clanCounter;

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

  mapping(uint256 => Proposal) public proposals;  // Proposal ID => Proposal
  mapping(uint256 => Round) public rounds;      // Proposal Number => Round
  mapping(uint256 => Clan) public clans;          // Clan ID => Clan info
  mapping(address => uint256) public clanOf;      // ID of the clan of an address
  mapping(uint256 => uint256) public clanCooldownTime;  // Cooldown time for each clan | Clan ID => Cooldown time
  mapping(address => mapping(uint256 => uint256)) public collectedTaxes;  // Receiver => Lord ID => Amount

  uint256 public currentTotalClanPoint;  
  uint256 public maxPointToChange;        // Maximum point that can be given in a propsal
  uint256 public cooldownTime;            // Cool down time to give clan point by executors
  uint256 public roundNumber;             // Tracking the round number

  constructor(){
    clanCounter.increment();  // clan ID's should start from 1
    maxPointToChange = 666;
    cooldownTime = 3 days;

    // Set the round contract address and get the current round number from it
    contracts[9] = 0x0000000000000000000000000000000000000000;
    (bool txSuccess0, bytes memory returnData) = contracts[9].call(abi.encodeWithSignature("getCurrentRoundNumber()"));
    require(txSuccess0, "Transaction has failed to get backer rewards from Token contract!");
    (roundNumber) = abi.decode(returnData, (uint256));
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
    ERC1155Burnable(contracts[1]).burn(_msgSender() ,_lordID , 1);

    uint256 clanID = clanCounter.current();

    // Register the clan to the lord
    bytes memory payload = abi.encodeWithSignature("clanRegistration(uint256,uint256)", _lordID, clanID);
    (bool txSuccess, ) = address(contracts[7]).call(payload);
    require(txSuccess, "Transaction has fail to register clan to the Lord contract!");

    // Create the clan
    Clan storage clan = clans[clanID];
    clanCounter.increment();

    clan.leader = _msgSender();
    clan.lordID = _lordID;
    clan.name = _clanName;
    clan.description = _clanDescription;
    clan.motto = _clanMotto;
    clan.logoURI = _clanLogoURI;
    clan.memberIdOf[_msgSender()] = 0; // Assign the first ID to the leader

    // Sign the leader as a member of the clan as well and give full authority
    clan.members[0].isMember = true;
    clan.members[0].isExecutor = true;
    clan.members[0].isMod = true;
    clan.members[0].memberAddress = _msgSender();

    clan.memberCounter.increment(); // Increament the counter to 1 from 0
  }

  function declareClan(uint256 _clanID) public {
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");
    
    address sender = _msgSender();
    Clan storage currClan = clans[clanOf[sender]];
    uint256 memberID = currClan.memberIdOf[sender];

    // Erase data from the current clan
    currClan.members[memberID].isMember = false;
    currClan.members[memberID].isExecutor = false;
    currClan.members[memberID].isMod = false;

    // Keep record of the new clan ID of the address
    // Note: By default, everyone a member of all clans. Being a true member requires at least 1 point.
    clanOf[sender] = _clanID; 
  }

  /**
    @dev Only the Executors can give clan point. 
    There is a cooldown time to avoid executors change clan point as they wish.
    Executors can give clan point on for the current round.
  */
  function giveClanPoint(uint256 _clanID, uint256 _point, bool _isDecreasing) public {
    require(_msgSender() == contracts[5], "Only Executors can call this function!"); 
    require(_point <= maxPointToChange, "Maximum amount of point exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");
    
    // Wait if the cooldown time is not passed. Avoids executors to change point as they wish!
    require(block.timestamp > clanCooldownTime[_clanID], "Wait for the cooldown time!");
    clanCooldownTime[_clanID] = block.timestamp + cooldownTime; // set a new cooldown time

    // If the are in the new round
    checkAndUpdateRound();

    Clan storage clan = clans[_clanID];

    // Update clan point before interact with them. Not member (0)
    updatePoint(_clanID, address(0));
    
    if (_isDecreasing){
      clan.point[roundNumber] -= _point;
      clan.currentPoint -= _point;
      rounds[roundNumber].totalClanPoint -= _point;
      currentTotalClanPoint -= _point;
    }
    else {
      clan.point[roundNumber] += _point;
      clan.currentPoint += _point;
      rounds[roundNumber].totalClanPoint += _point;
      currentTotalClanPoint += _point;
    }

    // If this was the first time of this clan, record the first round
    if (clan.firstRound == 0) { clan.firstRound = roundNumber; }
  }

  function clanRewardClaim(uint256 _clanID, uint256 _roundNumber) public {    
    require(clans[_clanID].leader != address(0), "There is no such clan with that ID!");

    // If the are in the new round
    checkAndUpdateRound();

    require(_roundNumber < roundNumber, "You can't claim the current or future rounds' rounds. Check round number!");
    BUG: roundNumber diyor?
    require(rounds[roundNumber].isClanClaimed[_clanID] == false, "Your clan already claimed its reward for this round!");
    rounds[roundNumber].isClanClaimed[_clanID] == true;  // If not claimed yet, mark it claimed.

    Clan storage clan = clans[_clanID];

    // Update clan point before interact with them. Not member (0)
    updatePoint(_clanID, address(0));  

    // total clan reward * clan Point * 100 / total clan point
    uint256 reward = rounds[roundNumber].clanRewards * (clan.point[_roundNumber] * 100 / rounds[roundNumber].totalClanPoint);
    rounds[roundNumber].claimedRewards += reward;  // Keep record of the claimed rewards

    // Get the address and the tax rate of the lord
    (bool txSuccess1, bytes memory returnData1) = address(contracts[7]).call(abi.encodeWithSignature("lordTaxInfo(uint256)", clan.lordID));
    require(txSuccess1, "Failed to get the address of the lord!");
    (address lordAddress, uint256 taxRate) = abi.decode(returnData1, (address, uint256));

    // Get the lord tax and update the reward after tax //["0xd9145CCE52D386f254917e481eB44e9943F39138", "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8"]
    uint256 lordTax = reward * taxRate / 100;
    reward -= lordTax;

    // Then transfer the taxes if there lord address exist. (which means lord is alive)
    if (lordAddress != address(0))
      IERC20(contracts[11]).transfer(lordAddress, lordTax);

    // Then keep the remaining for the clan
    clan.rewards[roundNumber] = reward;
    clan.balance += reward;
  }

  function memberRewardClaim(uint256 _clanID, uint256 _roundNumber) public {
    // If the are in the new round
    checkAndUpdateRound();

    Clan storage clan = clans[_clanID];
    uint256 _round = _roundNumber;
    address sender = _msgSender();
    uint256 memberID = clan.memberIdOf[sender];
    
    require(clan.members[memberID].isMember, "You are not a member of this clan!");
    require(3 <= roundNumber, "Wait for the first 3 round to finish to have finalized reward!"); BUG
    require(_round <= roundNumber - 3, "You can't claim the reward until it finalizes. Rewards are getting finalized after 3 rounds!");
    require(clan.isMemberClaimed[_round][sender] == false, "You already claimed your reward for this round!");
    clan.isMemberClaimed[_round][sender] == true;  // If not claimed yet, mark it claimed.

    // Update clan point before interact with them.
    updatePoint(_clanID, sender);  

    // if clan reward is not claimed by clan executors or the leader, claim it.
    if (clan.rewards[_round] == 0) { clanRewardClaim(_clanID, _round); }      

    // calculate the reward and send it to the member!
    uint256 reward = // total reward of the clan * member Point * 100 / total member point of the clan
      clan.rewards[_round] * (clan.members[memberID].point[_round] * 100 / clan.totalMemberPoint[_round]);

    IERC20(contracts[11]).transfer(sender, reward);
    clan.balance -= reward; // Update the balance of the clan
    clan.claimedRewards[_round] += reward; // Update the claimed rewards

    // Mint FDAO tokens as much as the clan member reward
    (bool txSuccess,) = contracts[4].call(abi.encodeWithSignature("mintTokens(address,uint256)", sender, reward));
    require(txSuccess, "Transaction failed to mint new FDAO tokens!");
  }

  /// @dev Starts the new round if the time is up
  function checkAndUpdateRound() public {
    (bool txSuccess0, bytes memory returnData) = contracts[9].call(abi.encodeWithSignature("getCurrentRoundNumber()"));
    require(txSuccess0, "Transaction has failed to get backer rewards from Token contract!");
    (uint256 currentRound) = abi.decode(returnData, (uint256));

    // If the new round has started, get rewards from StickToken contract first
    if (currentRound > roundNumber){ 
      // Get the clans rewards from token
      (bool txSuccess0, bytes memory returnData0) = contracts[11].call(abi.encodeWithSignature("clanMint()"));
      require(txSuccess0, "Transaction has failed to get backer rewards from Token contract!");

      // Save the reward to the round
      (rounds[roundNumber].clanRewards) = abi.decode(returnData0, (uint256));

      // Keep the total clan point to pass on to the next round
      uint256 currentTotalClanPoint = rounds[roundNumber].totalClanPoint;

      // Pass on the current total clan point to the next round
      rounds[currentRound].totalClanPoint = currentTotalClanPoint;

      roundNumber = currentRound; // Save the new round number
    }
  }

  function updatePoint(uint256 _clanID, address _member) internal { 
    Clan storage clan = clans[_clanID];
    
    // Update clan point
    uint256 index = roundNumber;
    while (clan.point[index] == 0 && index > clan.firstRound) { index--; }
    clan.point[roundNumber] = clan.point[index];

    // Update total member point of the clan
    index = roundNumber;
    while (clan.totalMemberPoint[index] == 0 && index > clan.firstRound) { index--; }
    clan.totalMemberPoint[roundNumber] = clan.totalMemberPoint[index];
    
    // Member point of the clan
    if (_member == address(0)) { return; }  // If the member address is null, then skip it
    uint256 memberID = clan.memberIdOf[_member];
    index = roundNumber;
    while (clan.members[memberID].point[index] == 0 && index > clan.firstRound) { index--; }
    clan.members[memberID].point[roundNumber] = clan.members[memberID].point[index];
  }

  // Governance Functions
  function setClanMember(uint256 _clanID, address _address, bool _isMember) public {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[clan.memberIdOf[_address]];

    require(clanOf[_address] == _clanID, "The member should join the clan first!");
    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(clan.members[clan.memberIdOf[_msgSender()]].isMod, "You have no authority to moderate memberships for this clan!");
    require(clan.leader != _address, "You can't set the leader as a member!");

    if (_isMember) {
      require(_clanID == clanOf[_address], "The address you wish to set as member should declare its clan first!");
      member.isMember = true;

      uint256 currentID = clan.memberCounter.current();
      // if the member doesn't have any previous id
      if (member.memberID == 0) { 
        member.memberID = currentID;
        member.memberAddress = _msgSender();

        clan.memberIdOf[_msgSender()] = currentID; 
        clan.lastMemberID = currentID;     
        clan.memberCounter.increment();
      }
    }
    else { 
      member.isMember = false; 
      clan.memberCounter.decrement();
      // Keeps the member ID with it
    }
  }

  function setClanExecutor(uint256 _clanID, address _address, bool _isExecutor) public  {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[clan.memberIdOf[_address]];

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(_msgSender() == clan.leader, "You have no authority to give Executor Role for this clan!");

    if (_isExecutor) { member.isExecutor = true; }
    else { member.isExecutor = false; }
  }

  function setClanMod(uint256 _clanID, address _address, bool _isMod) public  {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[clan.memberIdOf[_address]];

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(_msgSender() == clan.leader, "You have no authority to give Executor Role for this clan!");

    if (_isMod) { member.isMod = true; }
    else { member.isMod = false; }
  }

  function giveMemberPoint(uint256 _clanID, address _memberAddress, uint256 _point, bool _isDecreasing) public nonReentrant() {
    Clan storage clan = clans[_clanID];
    ClanMember storage member = clans[_clanID].members[clan.memberIdOf[_memberAddress]];
    
    checkAndUpdateRound();

    require(clan.isDisbanded == false, "This clan is disbanded!");
    require(clan.members[clan.memberIdOf[_msgSender()]].isExecutor, "You have no authority to give point for this clan!");
    require(clan.members[clan.memberIdOf[_memberAddress]].isMember, "The address is not a member!");

    // Update clan point before interact with them.
    updatePoint(_clanID, _memberAddress);  

    // Update member point and total member point of the clan
    if (_isDecreasing) {
      member.point[roundNumber] -= _point;
      member.currentPoint -= _point;
      clan.totalMemberPoint[roundNumber] -= _point;
      clan.currentTotalMemberPoint -= _point;
    }
    else {
      member.point[roundNumber] += _point;
      member.currentPoint += _point;
      clan.totalMemberPoint[roundNumber] += _point;
      clan.currentTotalMemberPoint += _point;
    }
  }

  function signalRebellion(uint256 _clanID) public {
    Clan storage clan = clans[_clanID];

    require(clan.isDisbanded == false, "This clan is disbanded!");    
    require(clan.members[clan.memberIdOf[_msgSender()]].isExecutor, "You have no authority to signal a rebellion for this clan!");

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
  
  // Returns the real clan of an address. Only members with point are real members, others are default
  function getClan(address _address) public view returns (uint256) {
    Clan storage clan = clans[clanOf[_address]];
    return clan.members[clan.memberIdOf[_address]].isMember ? clanOf[_address] : 0;
  }

  // Returns true if the member is an executor in its clan
  function isMemberExecutor(address _memberAddress) public view returns (bool) {
    Clan storage clan = clans[clanOf[_memberAddress]];
    return clan.members[clan.memberIdOf[_memberAddress]].isExecutor;
  }

  // Returns true if the member is an executor in its clan
  function isMemberMod(address _memberAddress) public view returns (bool) {
    Clan storage clan = clans[clanOf[_memberAddress]];
    return clan.members[clan.memberIdOf[_memberAddress]].isMod;
  }

  // Returns the member's point
  function getMemberPoint(address _memberAddress) public returns (uint256) {
    Clan storage clan = clans[clanOf[_memberAddress]];
    uint256 clanID = clanOf[_memberAddress];
    ClanMember storage member = clans[clanOf[_memberAddress]].members[clan.memberIdOf[_memberAddress]];

    // Update clan point before interact with them.
    checkAndUpdateRound();
    updatePoint(clanID, _memberAddress); 

    return member.point[roundNumber];
  }

  // returns all the members' point along with IDs
  function getPointsOf(uint256 _clanID) public view returns 
    (uint256, uint256, uint256, address[] memory, uint256[] memory, uint256[] memory) 
  {
    Clan storage clan = clans[_clanID];
    //ClanMember storage member = clans[_clanID].members[_address];

    uint256 lastID = clan.lastMemberID;
    uint256 memberCount = clan.memberCounter.current();
    uint256[] memory ids = new uint[](memberCount);
    uint256[] memory points  = new uint[](memberCount);
    address[] memory addresses  = new address[](memberCount);

    uint256 skipped;
    for (uint256 id = 0; id < lastID; id++) {

      // skip the non-members
      if (!clan.members[id].isMember) {
        skipped++;
        continue;
      } 

      ids[id - skipped] = id;
      points[id - skipped] = clan.members[id].currentPoint;
      addresses[id - skipped] = clan.members[id].memberAddress;
    }

    return (currentTotalClanPoint, clan.currentPoint, clan.currentTotalMemberPoint, addresses, ids, points);
  }

  /**
    Updates by DAO - Update Codes
    
    Contract Address Change -> Code: 1
    Proposal Type Change -> Code: 2
    maxPointToChange -> Code: 3
    cooldownTime -> Code: 4
    clan Point Adjustment -> Code: 5 
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
      "In Clan contract, updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
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
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating maximum clan point to change at a time to ",
      Strings.toHexString(_newMaxPoint), " from ", Strings.toHexString(maxPointToChange), "."
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
      maxPointToChange = proposal.newUint;

    proposal.isExecuted = true;
  }

  function proposeCooldownTimeUpdate(uint256 _newCooldownTime) public {
    require(_msgSender() == contracts[5], "Only executors can call this function!");

    string memory proposalDescription = string(abi.encodePacked(
      "In Clan contract, updating cooldown time (Unix Time) to ",
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
    @notice Anyone can propose point adjustmen right after the round is complete and until the next round.
    You can't propose a new proposal until the current proposal gets executed
   */ 
  function proposeClanPointAdjustment(uint256 _roundNumber, uint256 _clanID, uint256 _pointToChange, bool _isDecreasing) public {
    require(_pointToChange <= maxPointToChange, "Maximum amount of point exceeded!");
    require(clans[_clanID].isDisbanded == false, "This clan is disbanded!");

    // If the are in the new round
    checkAndUpdateRound();

    Clan storage clan = clans[_clanID];

    // After end of the round but until the end of the second round
    require(_roundNumber == roundNumber - 1, "Invalid round number!");

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

    // Check round update
    checkAndUpdateRound();

    // Update clan point before interact with them. Not member (0)
    updatePoint(proposal.index, address(0));


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

    // If this was the first time of this clan to get point, record the first round
    if (clan.firstRound == 0) { clan.firstRound = roundNumber; }    
  }
}