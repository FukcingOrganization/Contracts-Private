// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
  * @notice:
  * -> maxSupply can change by DAO 13 days long proposal with %90 approval rate after there is 1 month left until the max supply
  * -> Mint rate can chage with same hard approval after 1 year: backers, clans, community, staking
  * -> Make changable all the receivers except airdrop and team. The address of them.
  */

/**
  * -> Vesting Mechanism                                                        //   Ether per sec         Wei per sec
  * Backers     -> Seance gets automatically        // 7days (0.6%) TGE         // 0.224538876188384    224538876188384000
  * Clans       -> Clan contract gets automatically                             // 0.224538876188384    224538876188384000
  * Community   -> Executors pulls to the contract  // 13% TGE                  // 0.0748462920627947   74846292062794700
  * Staking     -> Executors pulls to the contract  // New Contract (later)     // 0.0748462920627947   74846292062794700
  * FDAO        -> Executors pulls to the contract                              // 0.0374231460313974   37423146031397400
  * Executors   -> Executors pulls to the contract                              // 0.0149692584125589   14969258412558900
  * Airdrop     -> Individual claim with 66 Level   // 1 yr - 13% TGE           // 0.0374231460313974   112269438094192000
  * Dev         -> Executors pulls to a EOA         // 1 yr                     // 0.0224538876188384   67361662856515200
  * Team        -> Individual claim                 // 1 yr                     // 0.0374231460313974   112269438094192000
  *
  * Clans' claim can not exceed the total supply of DAO tokens !! 
  * Therefore, DAO members (most of them are clans) should approve new DAO token mints that are proposed by the Executors.
  */

/*
 * @author Bora
 */

contract FukcingToken is ERC20, ERC20Burnable, ERC20Snapshot, Pausable {
    using Counters for Counters.Counter;   

    enum ProposalStatus{
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }

    struct Proposal {
        ProposalStatus status;
        string description;
    }

    Counters.Counter private proposalCounter;

    mapping(uint256 => Proposal) public proposals;          // proposalID => Proposal
    mapping(address => uint256) public allowancePerSecond;  // address => allowance per second in WEI
    mapping(address => uint256) public claimedAllowance;    // address => total claimed allowance

    address public fukcingDAO;
    address public fukcingExecutors;
    address public fukcingSeance;
    address public fukcingClan;
    address public fukcingCommunity;
    address public fukcingStaking;
    address public fukcingDevelopers;

    uint256[] public airdropMintPerSecond;
    bytes32[] public airdropRoots;
    address[] teamAddress;
    uint256[] teamMintPerSecond;

    uint256 public deploymentTime;
    uint256 public oneYearVesting = 31556926;   // TEST -> Change var name and value. Like: october_16_2023 = 1697471734;
    uint256 public communityTGErelease;         // 12,307,196   -> ~142 days
    uint256 public airdropTGErelease;           // 4,102,399    -> ~47 days
    uint256 public proposalType;
    uint256 public maxSupply = 70857567;        // ~70 million initial max supply
    uint256 public teamAndAirdropCap = 3542878; // ~3.5 million both for team and airdrop allocation

    // Mint per second in Wei
    uint256 public backerMintPerSecond = 224538876188384000;
    uint256 public clanMintPerSecond = 224538876188384000;
    uint256 public communityMintPerSecond = 74846292062794700;
    uint256 public stakingMintPerSecond = 74846292062794700;
    uint256 public daoMintPerSecond = 37423146031397400;
    uint256 public executorsMintPerSecond = 14969258412558900;
    uint256 public developmentMintPerSecond = 67361662856515200;

    // Minted Amount for each allocation subject    
    uint256 public totalBackerMint;
    uint256 public totalClanMint;
    uint256 public totalCommunityMint;
    uint256 public totalStakingMint;
    uint256 public totalDaoMint;
    uint256 public totalExecutorsMint;
    uint256 public totalAirdropMint;
    uint256 public totalDevelopmentMint;
    uint256 public totalTeamMint;
    
    constructor(
        address[] memory _teamAddress,
        uint256[] memory _teamMintPerSecond,
        bytes32[] memory _airdropRoots,
        uint256[] memory _airdropMintPerSecond
    ) 
        ERC20("FukcingToken", "FUKC") 
    {
        deploymentTime = block.timestamp;
        teamAddress = _teamAddress;
        teamMintPerSecond = _teamMintPerSecond;
        airdropRoots = _airdropRoots;
        airdropMintPerSecond = _airdropMintPerSecond;
        
        // Start with index of 1 to avoid some double propose in state updates
        proposalCounter.increment(); 
    }

    function snapshot() public {
        require(_msgSender() == fukcingExecutors, "Only executor contract can call this function!");
        _snapshot();
    }

    function pause() public {
        require(_msgSender() == fukcingExecutors, "Only executor contract can call this function!");
        _pause();
    }

    function unpause() public {
        require(_msgSender() == fukcingExecutors, "Only executor contract can call this function!");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Vesting Mechanism - Dynamic Mint 

    function backerMint() public returns (uint256){
        require(_msgSender() == fukcingSeance, "Only the Fukcing Seance contract can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");

        // Mint starts 7 days before the token deployment to reward backers and players for the initial seance
        uint256 totalReward = (block.timestamp - (deploymentTime - 7 days)) * backerMintPerSecond; // TEST -> make it 7 days
        uint256 currentReward = totalReward - totalBackerMint;

        totalBackerMint += currentReward;

        _mint(fukcingSeance, currentReward);

        return currentReward;
    }

    function clanMint() public returns (uint256){
        require(_msgSender() == fukcingClan, "Only the Fukcing Clan contract can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");

        uint256 totalReward = (block.timestamp - deploymentTime) * clanMintPerSecond;
        uint256 currentReward = totalReward - totalClanMint;

        // DAO token supply should be equal or greater than the total clan reward 
        // to encourage DAO members to approve new mint proposals.
        require(ERC20(fukcingDAO).totalSupply() >= totalReward, "Not enough DAO tokens! DAO should approve new token mints!");

        totalClanMint += currentReward;

        _mint(fukcingClan, currentReward);

        return currentReward;
    }

    function communityMint() public returns (uint256){
        require(_msgSender() == fukcingCommunity, "Only the Fukcing Community can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        // Community mint date starts ~142 days ago to have 13% TGE which is 921k tokens.
        uint256 totalReward = (block.timestamp - (deploymentTime - communityTGErelease)) * communityMintPerSecond;
        uint256 currentReward = totalReward - totalCommunityMint;

        totalCommunityMint += currentReward;

        _mint(fukcingCommunity, currentReward);

        return currentReward;
    }

    function stakingMint() public returns (uint256){        
        require(_msgSender() == fukcingExecutors, "Only the Fukcing Executors can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * stakingMintPerSecond;
        uint256 currentReward = totalReward - totalStakingMint;

        totalStakingMint += currentReward;

        _mint(fukcingStaking, currentReward);

        return currentReward;
    }

    function daoMint() public returns (uint256){        
        require(_msgSender() == fukcingExecutors, "Only the Fukcing Executors can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * daoMintPerSecond;
        uint256 currentReward = totalReward - totalDaoMint;

        totalDaoMint += currentReward;

        _mint(fukcingDAO, currentReward);

        return currentReward;
    }

    function executorsMint() public returns (uint256){        
        require(_msgSender() == fukcingExecutors, "Only the Fukcing Executors can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * executorsMintPerSecond;
        uint256 currentReward = totalReward - totalExecutorsMint;

        totalExecutorsMint += currentReward;

        _mint(fukcingExecutors, currentReward);

        return currentReward;
    }

    function airdropMint(bytes32[] calldata _merkleProof) public {
        require(block.timestamp <= oneYearVesting - airdropTGErelease, "Airdrop vesting period ended!");
        require(totalAirdropMint <= teamAndAirdropCap, "All of airdrop allocation has been minted!");

        
        uint256 totalReward = getAirdropReward(_merkleProof);
        require(totalReward > 0, "Bruh, you don't have any allowance! Maybe next time ;)");

        uint256 currentReward = totalReward - claimedAllowance[_msgSender()];
        claimedAllowance[_msgSender()] += currentReward;
        totalAirdropMint += currentReward;

        _mint(_msgSender(), currentReward);
    }

    function developmentMint() public returns (uint256){        
        require(_msgSender() == fukcingExecutors, "Only the Fukcing Executors can call this fukcing function!");
        require(block.timestamp <= oneYearVesting, "Development vesting period ended!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * developmentMintPerSecond;
        uint256 currentReward = totalReward - totalDevelopmentMint;

        totalDevelopmentMint += currentReward;

        _mint(fukcingDevelopers, currentReward);

        return currentReward;
    }

    function teamMint(uint256 _index) public {
        require(_msgSender() == teamAddress[_index], "You don't share the team allocation, check your wallet address! Dummy!");
        require(block.timestamp <= oneYearVesting, "Team vesting period ended!");
        require(totalTeamMint <= teamAndAirdropCap, "The team members minted all of their allocation!");

        uint256 totalReward = (block.timestamp - deploymentTime) * teamMintPerSecond[_index];
        uint256 currentReward = totalReward - claimedAllowance[teamAddress[_index]];

        claimedAllowance[teamAddress[_index]] += currentReward;
        totalTeamMint += currentReward;

        _mint(teamAddress[_index], currentReward);
    }

    function getAirdropReward(bytes32[] calldata _merkleProof) internal view returns (uint256) {
        uint256 totalReward;
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        // Search in all roots
        for (uint256 i = 0; i < airdropRoots.length; i++){

            // If the proof valid for this index, get the reward for this index
            if (MerkleProof.verify(_merkleProof, airdropRoots[i], leaf)){

                // Community mint date starts ~142 days ago to have 13% TGE which is 921k tokens.
                totalReward = (block.timestamp - (deploymentTime - airdropTGErelease)) * airdropMintPerSecond[i];
                break;
            }
        }

        return totalReward;
    }


/*
    function updateFukcingDAOContractAddress(address _newAddress) public returns (bool) {
        // if stateUpdateID is 0, make a new proposal
        if (stateUpdateID_lordContAdd == 0) { // Which is default
            string memory proposalDescription = string(abi.encodePacked(
                "Update Fukcing Lord Contract address to ", Strings.toHexString(_newAddress), 
                " from ", Strings.toHexString(fukcingLordContract), "."
            )); 
            // Create a new proposal and save the ID
            stateUpdateID_lordContAdd = newProposal(proposalDescription, stateUpdateProposalType);

            // Get new state update by proposal ID we get from newProposal
            StateUpdate storage update = stateUpdates[stateUpdateID_lordContAdd];
            update.proposalID = stateUpdateID_lordContAdd;
            update.newAddress = _newAddress;

            // Finish the function
            return true;
        }

        // If there is already a proposal, Update the current proposal
        Proposal storage proposal = proposals[stateUpdateID_lordContAdd];
        updateProposalStatus(proposal);

        // Wait for the current one to finalize
        string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
            " Wait for the DAO decision on the proposal! The proposal ID = ", Strings.toString(proposal.id), "."
        )); 
        require(uint256(proposal.status) > 1, errorText);

        // if the current one is approved, apply the update the state
        if (proposal.status == ProposalStatus.Approved){
            StateUpdate storage update = stateUpdates[stateUpdateID_lordContAdd];
            fukcingLordContract = update.newAddress;
            stateUpdateID_lordContAdd = 0;   // reset proposal tracker
            return true;
        } else {  // if failed, change the stateUpdateNum to 0 and return false 
            stateUpdateID_lordContAdd = 0;   // reset proposal tracker
            return false;
        }  
    }
*/
}


