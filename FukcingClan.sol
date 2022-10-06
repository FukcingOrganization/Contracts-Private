// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
/**
  * -> Has lord, clan treasury balance
  * -> levelOf that controls the clans
  * -> Clan proposals? Leader can set who can propose important change and general proposal, and approval rate.
  * ----> Once the leader give the power to other people, they has to act together.
  * -> Clan officials distributes the reward by rank  
  * -> Clan tax, points, level, and country Code
  * -> Disbanding the clan
  * -> Executers can add new points (DAO), can change the country code (just executers)
  * -> Update: DAO and Executer add, UpdatePropType, points for levels, Clan tax for members, country Code
  */

/*
 * @author Bora
 */

/**
  * Constructor: sender -> leader
  * 
  * Leader can set a rank to make significant changes
  **/

contract FukcingClan is Context, ReentrancyGuard {
  struct ClanMember {
    uint256 points;
    bool isExecutor;
  }

  struct Clan {
    address founder;
    uint256 lordID;
    uint256 clanBalance;
    uint256 clanPoints;

    mapping(address => ClanMember) members;
    uint256 totalMemberPoints;

    bool canExecutorsSignalRebellion;
    bool canExecutorsSetPoints;
  } 

  mapping(uint256 => Clan) public clans;
  mapping(address => uint256) public clanOf; // ID of the clan of an address

  uint256 totalClanPoints;

  constructor(){
  }

  function createClan(uint256 _lordID) public nonReentrant() {

  }

  function joinToClan(uint256 _clanID) public {
    require(clans[_clanID].founder != address(0), "There is no such clan with that ID!");

    // Erase data from the previous clan
    ClanMember storage member = clans[_clanID].members[_msgSender()];
    uint256 memberPoints = member.points;
    member.points = 0;
    member.isExecutor = false;
    clans[_clanID].totalMemberPoints -= memberPoints;

    // Join the new clan
    clanOf[_msgSender()] = _clanID;
  }

  // Governance Functions
  function setPoints(uint256 _clanID, address _account, uint256 _points) public nonReentrant() {
    Clan storage clan = clans[_clanID];

    if (clan.canExecutorsSetPoints){
      require(clan.founder == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to set points for this clan!"
      );
    }
    else{      
      require(clan.founder == _msgSender(), "You have no authority to set points for this clan!");
    }

    ClanMember storage member = clans[_clanID].members[_account];
    require(member.points != _points, "The member has the exact points already!");
    
    // Update total member points of the clan
    if (_points > member.points)
      clan.totalMemberPoints += _points - member.points;
    else
      clan.totalMemberPoints -= member.points - _points;
    // Set the point
    member.points = _points;
  }

  function setExecutor(uint256 _clanID, address _account, bool _isExecutor) public  {
    require(clans[_clanID].founder == _msgSender(), "You have no authority to set a rank for this clan!");

    clans[_clanID].members[_account].isExecutor = _isExecutor;
  }

  function signalRebellion(uint256 _clanID) public {
    Clan storage clan = clans[_clanID];
    
    if (clan.canExecutorsSignalRebellion){
      require(clan.founder == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to signal a rebellion for this clan!"
      );
    }
    else{      
      require(clan.founder == _msgSender(), "You have no authority to signal a rebellion for this clan!");
    }

    // Signal a rebellion
  }

  function setClanPoints(uint256 _clanID, uint256 _points) public {
    //require(/* Only by executor contract */);


    /// !!!!!!!!!! What happens when clan executors change someone's point while clan has remaining balance? Then remaining people can't get their allowance fairly. Same for clans as well. !!!!!


    /*
    Clan storage clan = clans[_clanID];

    if (clan.canExecutorsSetPoints){
      require(clan.founder == _msgSender() || clan.members[_msgSender()].isExecutor, 
        "You have no authority to set points for this clan!"
      );
    }
    else{      
      require(clan.founder == _msgSender(), "You have no authority to set points for this clan!");
    }

    ClanMember storage member = clans[_clanID].members[_account];
    require(member.points != _points, "The member has the exact points already!");
    
    // Update total member points of the clan
    if (_points > member.points)
      clan.totalMemberPoints += _points - member.points;
    else
      clan.totalMemberPoints -= member.points - _points;
    // Set the point
    member.points = _points;
    */
  }
}