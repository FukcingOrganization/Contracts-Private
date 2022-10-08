// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


/*
 * @author Bora
 */

/**
  * @notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */
contract FukcingToken is ERC20, AccessControl {
    using Counters for Counters.Counter;   

    enum ProposalStatus{
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }
    struct Proposal {
        uint256 proposalID;
        ProposalStatus status;
        string description;
    }

    bytes32 public constant EXECUTER_ROLE = keccak256("EXECUTER_ROLE");
    
    Counters.Counter private proposalCounter;

    mapping (uint256 => Proposal) public proposals; // proposalID => Proposal
    
    address public fukcingDAOContract;

    constructor() ERC20("FukcingToken", "FUKC") {
        // The owner starts with a small balance to approve the first mint issuance. 
        // Will change with a new mint approval in the first place to start decentralized.
        _mint(msg.sender, 1024 ether); // Start with 1024 token. 1 for each lord NFT TEST -> send 512 token to the lord balance
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXECUTER_ROLE, msg.sender);

        // Initial settings
/*
        initializeProposalTypes();
        stateUpdateProposalType = 5; // TEST -> make it type = 3, which is 3 days
        monetaryProposalType = 5; // TEST -> make it type = 3, which is 3 days TEST ---->> Create a 2 days type and make this 2 days because we have 3 monetary prop
        minBalanceToPropose = 1000; // 1000 tokens without decimals
*/
        // Start with index of 1 to avoid some double propose in satate updates
        proposalCounter.increment(); 
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
  * -> Vesting Mechanism
  * -> Adjusting Max Supply for game rewards by DAO proposal if we have reached the max supply!
  * -> Add non retantdundudasnduns
  * -> Update: DAO and Executer add, UpdatePropType, (Airdrop, Team, 
  */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/*
 * @author Bora
 */
contract FukcingToken is ERC20, AccessControl, ERC20Burnable {
    using Counters for Counters.Counter;   

    enum ProposalStatus {
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }
    struct Proposal {
        uint256 proposalID;
        ProposalStatus status;
        string description;
    }

    bytes32 public constant EXECUTER_ROLE = keccak256("EXECUTER_ROLE");
    
    Counters.Counter private proposalCounter;

    mapping(uint256 => Proposal) public proposals; // proposalID => Proposal
    mapping(address => uint256) public allowancePerSecond;
    mapping(address => uint256) public claimedVesting;
    
    address public fukcingDAOContract;

    constructor() ERC20("FukcingToken", "FUKC") {
        _mint(msg.sender, 1024 ether);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXECUTER_ROLE, msg.sender);
    }
/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                           >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><                      Vesting Mechanism                      >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                           >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/
    function updateFukcingDAOContractAddress(address _newAddress) public onlyRole(EXECUTER_ROLE) returns (bool) {
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
}