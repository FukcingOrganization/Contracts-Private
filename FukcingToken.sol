// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
//import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
  * @notice:
  * -> Add snapshot feature. Executors can take snapshot.
  * -> The receiver address of the staking rewards should be empty and will be set by the DAO decision later when we figure out how to set the staking stuff.
  */

/**
  * -> Vesting Mechanism                                                        //   Ether per sec         Wei per sec
  * Backers     -> Seance gets automatically                                    // 0.224538876188384    224538876188384000
  * Clans       -> Clan contract gets automatically                             // 0.224538876188384    224538876188384000
  * Community   -> Executors pulls to the contract  // New Contract - 13% TGE   // 0.0748462920627947   74846292062794700
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

    uint256[] public testerAllowance;
    uint256[] public testerRoots;
    uint256[] teamAllowance;
    uint256[] teamRoots;

    uint256 public deploymentTime;
    uint256 public oneYearVesting;
    uint256 public proposalType;

    // Mint per second in Wei
    uint256 public backerMintPerSecond;
    uint256 public clanMintPerSecond;
    uint256 public communityMintPerSecond;
    uint256 public stakingMintPerSecond;
    uint256 public daoMintPerSecond;
    uint256 public executorsMintPerSecond;
    uint256 public developmentMintPerSecond;

    function backerClaim() public {
        
    }
    
    constructor() ERC20("FukcingToken", "FUKC") {
        deploymentTime = block.timestamp;
        oneYearVesting = 1665946534;    // TEST -> Change var name and value. Like: october_16_2023 = 1697471734;
        
        // Start with index of 1 to avoid some double propose in state updates
        proposalCounter.increment(); 

        // _mint(to, amount);
        backerMintPerSecond = 224538876188384000;
        clanMintPerSecond = 224538876188384000;
        communityMintPerSecond = 74846292062794700;
        stakingMintPerSecond = 74846292062794700;
        daoMintPerSecond = 37423146031397400;
        executorsMintPerSecond = 14969258412558900;
        developmentMintPerSecond = 67361662856515200;
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


