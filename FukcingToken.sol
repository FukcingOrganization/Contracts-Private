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