// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
  * @notice
  * -> SDAO tokens are non-transferable! Therefore, you can't buy the governance,
  * you can't transfer the governance! You should earn it.
  *
  * -> Executors of Stick Fight proposes new updated and SDAO decide wheter apply or deny
  * the update. These updates are fully on-chain and not optional for the team to apply.
  *
  * -> Addresses with a minimum balance to propose can propose new custom proposals to
  * show community's decision on specific topics.
  *
  * -> SDAO issues the new SDAO tokens for distribution to designated accounts.
  *
  * -> The DAO has 5% allocation of STICK tokens. The DAO will vote for spending of these tokens
  * alongside with other ERC20 tokens and native coins that might be donated to the DAO.
  *
  * -> Lords represents 50% of the DAO. The lord contract holds 50% of SDAO tokens.
  */

/*


                                ⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀⢸⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀   ⣿⣉⠉⠻⠿⠿⠇⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀ ⠀⠀⠀⠀  ⣴⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀ ⠀⠀⢠⣤⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⡄⠀⠀⠀⠀⠀
                                ⠀⠀ ⠀⠀⠀⠸⢿⣿⣿⡿⠿⢿⣿⣿⡿⠿⢿⣿⣿⡿⠇⠀⠀⠀⠀⠀
                                ⠀ ⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⡇⠀ ⠀⠀⠀⠀⠀
                                 ⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⡇⠀⠀      ⠀⠀⠀⠀
                                ⢠⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡄
                                ⣿⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿⣿
                                ⣿⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿⣿
                                ⣿⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿   ⣿⣿⣿⣿
                                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿                                                         
                      
                                                                                                                              
                        MMP""MM""YMM `7MM          db              `7MMF'                                   
                        P'   MM   `7   MM                            MM                                     
                             MM        MMpMMMb.  `7MM  ,pP"Ybd       MM  ,pP"Ybd              
                             MM        MM    MM    MM  8I   `"       MM  8I   `"             
                             MM        MM    MM    MM  `YMMMa.       MM  `YMMMa.     
                             MM        MM    MM    MM  L.   I8       MM  L.   I8             
                           .JMML.    .JMML  JMML..JMML.M9mmmP'     .JMML.M9mmmP'             
                                                                                                         
                                                                                                                                                                   
`7MM"""Yb.      db       .g8""8q.   
  MM    `Yb.   ;MM:    .dP'    `YM. 
  MM     `Mb  ,V^MM.   dM'      `MM 
  MM      MM ,M  `MM   MM        MM 
  MM     ,MP AbmmmqMA  MM.      ,MP 
  MM    ,dP'A'     VML `Mb.    ,dP' 
.JMMmmmdP'.AMA.   .AMMA. `"bmmd"'                                                                                                             


*/

/*
    We are the StickDAO. We make our changes as possible as on-chain and fair!

    The Stick DAO tokens are not transferable!
    Therefore you can't buy them, you have to earn them!
    SDAO token is based on ERC-20 standard and manipulated to be non-transferable.

    What does DAO do?
    - Issues new SDAO tokens.
    - Approves all economic changes in Stick Fight.
    - Provides a on-chain voting mechanism for both off-chain and on-chain changes.
    - The Lords represent 50% of the DAO.

    Jump to line X to see the codes of the DAO.
    The other codes are updated openzepplin contracts to be a non-transferable token.
    We simply removed transfer, approve, allowance functions and events.

    Only 1 monetary proposal can be active at a time! Therefore, you need to wait for
    the current one to finalize to propose a new monetary proposal. There are 3 different
    monetary proposals: SDAO token mint, STICK token spending, Native Coin Spending.

    DAO will decide how to spend its treasury with monetary proposals.
*/

/// @author Bora
contract StickDAO is ERC20 {
    using Counters for Counters.Counter;   

    enum Status{
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }

    struct ProposalType{
        uint256 length;
        uint256 requiredApprovalRate;
        uint256 requiredTokenAmount;
        uint256 requiredParticipantAmount;
    }
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 proposalType;
        Status status;
        uint256 participants;
        uint256 totalVotes;
        uint256 yayCount;
        uint256 nayCount;
        mapping (address => bool) isVoted; // Voted EOAs
        mapping (uint256 => bool) isLordVoted; // Voted Lords lordID => true/false
    }

    struct SpendingProposal {
        Status status;
        uint256 proposalID;
        uint256 amount;             // It can be minting or spending amount
        address tokenAddress;       // For token spending proposals
        bytes32[] merkleRoots;
        uint256[] allowances;
        mapping (address => bool) claimed;
        // To keep track of total claimed funds to avoid double spending with a different proposal
        uint256 totalClaimedAmount; 
    }

    struct ProposalTypeUpdate {
        Status status;
        bool isExecuted;
        bool isNewType;
        uint256 proposalTypeNumber;
        uint256 newLength;
        uint256 newRequiredApprovalRate;
        uint256 newRequiredTokenAmount;
        uint256 newRequiredParticipantAmount;
    }

    struct ProposalTracker {
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
        If we want to change a function's proposal type, then we can simply change its type index

        Index : Associated Function
        0: New token spending
        1: New coin spending
        2: Contract address update
        3: Functions proposal types update
        4: Update minimum balance to propose
        5: Update minimum balance to propose clan point change
        6: Propose clan point change
        7: Propose a new proposal type & Update a proposal type
     */
    uint256[8] public functionsProposalTypes;

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
    
    Counters.Counter private proposalCounter;
    Counters.Counter private spendingProposalCounter;

    mapping(uint256 => Proposal) public proposals; // proposalID => Proposal
    mapping(uint256 => ProposalTracker) public proposalTrackers; // proposalID => Proposal Tracker
    mapping(uint256 => SpendingProposal) public spendingProposals;
    mapping(uint256 => ProposalTypeUpdate) public proposalTypeUpdates;  // proposalTypeUpdateID => ProposalTypeUpdate

    ProposalType[] public proposalTypes;

    uint256 public minBalanceToPropose;     // Amount of tokens without decimals

    constructor(address[13] memory _contracts) ERC20("StickDAO", "SDAO") {
        /*
         * The contract deployer starts with the smallest balance (0.0000000000000000001 token) 
         * to approve the initial configuration proposals. 
        **/
        _mint(_msgSender(), 100 ether);

        // Initial settings
        initializeProposalTypes();
        minBalanceToPropose = 100 ether; // TEST: Change it, the largest team member should be able to propose after 10 minutes
        contracts = _contracts;  // Set the existing contracts

        // Start with index of 1 to avoid some double propose in state updates
        proposalCounter.increment(); 
    }

    function DEBUG_setContract(address _contractAddress, uint256 _index) public {
        contracts[_index] = _contractAddress;
    }

    function DEBUG_setContracts(address[13] memory _contracts) public {
        contracts = _contracts;
    }

    // Events: event NewProposal(x, y); CapitalizedWords

    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><               Making The Token Non-Transferable              >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    /**
        @dev Making token non-transferable by overriding all the transfer functions
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        revert("This is a non-transferable token!");
    }

    function allowance(address owner, address spender) public virtual override view returns (uint256) {
        revert("This is a non-transferable token!");
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        revert("This is a non-transferable token!");
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        revert("This is a non-transferable token!");
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        revert("This is a non-transferable token!");
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
        revert("This is a non-transferable token!");
    }  
 
    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                       Proposal Mechanism                     >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //

    /* 
     * @dev New Proposal method returns the created proposal ID for the caller to track the result
     * To finalize a proposal, check the proposal result with isProposalPassed or proposalResult functions.
     */
    function newProposal(string memory _description, uint256 _proposalType) public returns(uint256) {
        // Detect if the caller is a contract
        bool isStickContract;
        for (uint i = 0; i < contracts.length; i++) { 
            if (_msgSender() == contracts[i]){ 
                isStickContract = true; 
                break; 
            }
        }

        // Only the contracts and the ones who has enough balance to propose can propose
        require(isStickContract || balanceOf(_msgSender()) >= minBalanceToPropose, 
            "You don't have enough voting power to propose, sorry dude!"
        );
        require(_proposalType >= 0 && _proposalType < proposalTypes.length, "Invalid proposal type you fool!");

        // Start with the current empty proposal
        Proposal storage proposal = proposals[proposalCounter.current()];

        proposal.id = proposalCounter.current();
        proposalCounter.increment();

        proposal.description = _description;
        proposal.startTime = block.timestamp;
        proposal.proposalType = _proposalType;
        proposal.status = Status.OnGoing;        

        return proposal.id; // return the current proposal ID
    }

    function vote(uint256 _proposalID, bool _isApproving) public {
        // Caller needs at least 1 token to vote!
        require(balanceOf(_msgSender()) >= 1 ether, "You don't have enough voting power, sorry dude!");

        Proposal storage proposal = proposals[_proposalID]; 
        updateProposalStatus(proposal);

        require(proposal.status == Status.OnGoing, "The proposal has ended my friend. Maybe another proposal?");
        require(!proposal.isVoted[_msgSender()], "You have already voted dude! Why too aggressive?");

        proposal.isVoted[_msgSender()] = true;

        // Removing decimals (1 ether) to avoid unnecessarily large numbers.
        uint256 votes = balanceOf(_msgSender()) / 1 ether;

        if (_isApproving){
            proposal.yayCount += votes;
        }
        else {    
            proposal.nayCount += votes;
        }
                
        proposal.participants++;
        proposal.totalVotes += votes;
    }

    /*
     *  @dev Only the Lord Contract can call this function to vote.
     */
    function lordVote(uint256 _proposalID, bool _isApproving, uint256 _lordID, uint256 _lordTotalSupply) 
    public returns (string memory) {
        require(_msgSender() == contracts[7], "Only the Lords can call this function! Go away, you prick!");

        Proposal storage proposal = proposals[_proposalID]; 
        updateProposalStatus(proposal);

        require(proposal.status == Status.OnGoing, "The proposal has ended my lord!");
        require(!proposal.isLordVoted[_lordID], "My lord, you have already voted!");

        proposal.isLordVoted[_lordID] = true;
        
        // Get the voting power of the lord: 
        // Lord voting power (aka. 50% of total supply of SDAO token) / lord total supply
        // Removing decimals (1 ether) to avoid unnecessarily large numbers.
        uint256 votes = balanceOf(contracts[7]) / _lordTotalSupply / 1 ether;

        if (_isApproving)
            proposal.yayCount += votes;
        else
            proposal.nayCount += votes;
                
        proposal.participants++;
        proposal.totalVotes += votes;

        return "Very wise decision my lord!";        
    }    

    // >< >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< >< ><                      Monetary Executions                     >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< //

    /**
        @dev Clan members mint as much SDAO tokens as they received in STICK token reward by Clan Rewards. 
        Therefore, only clan contract can call this functions and only clan members can mint new tokens.
        Total supply of SDAO tokens will be equal to total claimed clan rewards.
    */
    function mintTokens(address _minter, uint256 _amount) public {
        require(_msgSender() == contracts[1] || _msgSender() == contracts[11], 
            "Only the Clan and STICK token contracts can call this function!"
        );

        // Mint for the minter (The address that claims its clan reward).
        _mint(_minter, _amount);

        // Lords don't mint tokens themselves. Therefore, everyone mints for them as much as they mint for themselves.
        // And this is how Lords hold 50% of the balance and represent 50% of the DAO.
        _mint(contracts[7], _amount);   
    }

    // DAO Token Spendings
    function proposeNewTokenSpending(
        address _tokenContractAddress, 
        bytes32[] memory _merkleRoots, 
        uint256[] memory _allowances, 
        uint256 _totalSpending
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");

        // First of all, create a new monetary proposal and check the current slot is empty for a new one.
        SpendingProposal storage proposal = spendingProposals[spendingProposalCounter.current()];
        require(proposal.status == Status.NotStarted, "The current monetary proposal is not finalized bro! Come back later!");

        // Checking the balance of DAO in the target token
        bytes memory payload = abi.encodeWithSignature("balanceOf(address)", address(this));
        (bool txSuccess, bytes memory returnData) = _tokenContractAddress.call(payload);
        require(txSuccess, 
            "Balance check transaction failed! Check the address of the target token bro. It should have balanceOf(address account) function!"
        );

        // Get the balance from returned data and check if DAO has enough balance to spend or not!
        (uint256 DAObalance) = abi.decode(returnData, (uint256));
        require (DAObalance >= _totalSpending, "DAO has not enough balance to spend! Sad, isn't it?");

        // If all goes well, write the new proposal
        proposal.status = Status.OnGoing;
        proposal.amount = _totalSpending;
        proposal.tokenAddress = _tokenContractAddress;
        proposal.merkleRoots = _merkleRoots;
        proposal.allowances = _allowances;

        string memory proposalDescription = string(abi.encodePacked(
            "Spending ", Strings.toString(_totalSpending), " tokens from the ",
            Strings.toHexString(_tokenContractAddress), " contract address."
        ));
        
        proposal.proposalID = newProposal(proposalDescription, functionsProposalTypes[0]);
    }

    function claimTokenSpending(uint256 _spendingProposalNumber, bytes32[] calldata _merkleProof) public {
        SpendingProposal storage proposal = spendingProposals[_spendingProposalNumber];

        require(proposal.status == Status.Approved,
            "This proposal didn't pass or not finalized bro! Check your monetary proposal number!"
        );
        
        uint256 allowanceAmount = merkleCheck(proposal, _merkleProof);
        require(allowanceAmount > 0, "You don't have any allowance, sorry dude!"); 
        require(allowanceAmount + proposal.totalClaimedAmount <= proposal.amount, "The approved amount exceeding!");    

        // Send funds
        bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)", _msgSender(), allowanceAmount);
        (bool txSuccess, ) = proposal.tokenAddress.call(payload);
        require(txSuccess, "Token transfer transaction has failed!");

        // Keep track of claimed total amount
        proposal.totalClaimedAmount += allowanceAmount;
    }

    // DAO Native Coin Spendings
    function proposeNewCoinSpending(bytes32[] memory _merkleRoots, uint256[] memory _allowances, uint256 _totalSpending) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(address(this).balance >= _totalSpending, "DAO has not enough balance to spend! Sad, isn't it?");

        // Create a new monetary proposal and check the current slot is empty for a new one.
        SpendingProposal storage proposal = spendingProposals[spendingProposalCounter.current()];
        require(proposal.status == Status.NotStarted, "The current monetary proposal is not finalized bro! Come back later.");

        proposal.status = Status.OnGoing;
        proposal.amount = _totalSpending;
        proposal.merkleRoots = _merkleRoots;
        proposal.allowances = _allowances;

        string memory proposalDescription = string(abi.encodePacked("Spending of ", Strings.toString(_totalSpending), " coins"));
        
        proposal.proposalID = newProposal(proposalDescription, functionsProposalTypes[1]);
    }

    function claimCoinSpending(uint256 _spendingProposalNumber, bytes32[] calldata _merkleProof) public {
        SpendingProposal storage proposal = spendingProposals[_spendingProposalNumber];

        require(proposal.status == Status.Approved,
            "This proposal didn't pass or not finalized bro! Check your monetary proposal number!"
        );
        
        uint256 allowanceAmount = merkleCheck(proposal, _merkleProof);
        require(allowanceAmount > 0, "You don't have any allowance, sorry dude!");  
        require(allowanceAmount + proposal.totalClaimedAmount <= proposal.amount, "The approved amount exceeding!");        

        // Send funds
        (bool txSuccess, ) = payable(_msgSender()).call{value: allowanceAmount}('');
        require(txSuccess, "Transaction of sending coins failed! I donno why! Maybe problem on the network? Try it later on!");
        
        // Keep track of total claimed amount
        proposal.totalClaimedAmount += allowanceAmount;
    }

    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                    Updating State Variables                  >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    /**
     * Updates by DAO - Update Codes - Not required for monetaryUpdates and proposalTypeUpdates
     *
     * Contract Address Change -> Code: 1
     * Proposal Type Index Change -> Code: 2
     * minBalanceToProp -> Code: 3
     * 
     */

    function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
            "New address can not be the null or same address!"
        );

        string memory proposalDescription = string(abi.encodePacked(
        "In Stick DAO contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
            Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
        )); 

        // Create a new proposal
        uint256 propID = newProposal(proposalDescription, functionsProposalTypes[2]);

        // Save data to the proposal
        proposalTrackers[propID].updateCode = 1;
        proposalTrackers[propID].index = _contractIndex;
        proposalTrackers[propID].newAddress = _newAddress;
    }

    function executeContractAddressUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 1 && !proposal.isExecuted, "Wrong proposal ID");
        
        // Save the staus
        proposal.status = Status(proposalResult(_proposalID));

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if approved, apply the update the state
        if (proposal.status == Status.Approved)
            contracts[proposal.index] = proposal.newAddress;

        proposal.isExecuted = true;
    }

    function proposeFunctionsProposalTypesUpdate(uint256 _functionIndex, uint256 _newIndex) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(_newIndex != functionsProposalTypes[_functionIndex], "Desired function index is already set!");

        string memory proposalDescription = string(abi.encodePacked(
        "In Stick DAO contract, Updating proposal type indexes of index ", Strings.toHexString(_functionIndex), " to ", 
            Strings.toHexString(_newIndex), " from ", Strings.toHexString(functionsProposalTypes[_functionIndex]), "."
        )); 

        // Create a new proposal
        uint256 propID = newProposal(proposalDescription, functionsProposalTypes[3]);

        // Get data to the proposal
        proposalTrackers[propID].updateCode = 2;
        proposalTrackers[propID].index = _functionIndex;
        proposalTrackers[propID].newUint = _newIndex;
    }

    function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");

        // Save the staus
        proposal.status = Status(proposalResult(_proposalID));

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            functionsProposalTypes[proposal.index] = proposal.newUint;

        proposal.isExecuted = true;
    }    

    function proposeMinBalanceToPropUpdate(uint256 _newAmount) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");

        string memory proposalDescription = string(abi.encodePacked(
            "In Stick DAO contract, updating Minimum Balance To Propose to ", 
            Strings.toHexString(_newAmount), " from ", Strings.toHexString(minBalanceToPropose), "."
        )); 

        // Create a new proposal- proposal type Index : 2 - Highly Important
        uint256 propID = newProposal(proposalDescription, functionsProposalTypes[4]);

        // Save data to the local proposal
        proposalTrackers[propID].updateCode = 3;
        proposalTrackers[propID].newUint = _newAmount;
    }

    function executeMinBalanceToPropUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 3 && !proposal.isExecuted, "Wrong proposal ID");
        
        // Save the staus
        proposal.status = Status(proposalResult(_proposalID));

        // Check if it is finalized or not
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if the proposal is approved, apply the update the state
        if (proposal.status == Status.Approved)
            minBalanceToPropose = proposal.newUint;

        proposal.isExecuted = true;
    }

    /**
     * @dev To make a type inefective, set required amount to 1000000000 ether (1B token) and length to 0
     */
    function proposeNewProposalType(
        uint256 _length, 
        uint256 _requiredApprovalRate, 
        uint256 _requiredTokenAmount, 
        uint256 _requiredParticipantAmount
    ) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");

        string memory proposalDescription = string(abi.encodePacked(
            "Adding a new proposal type with following parameters: ", 
            "Length of ", Strings.toString(_length), ". ",
            "Required Approval Rate of ", Strings.toString(_requiredApprovalRate), ". ",
            "Required Token Amount of ", Strings.toString(_requiredTokenAmount), ". ",
            "Required Participant Amount of ", Strings.toString(_requiredParticipantAmount), "."
        ));

        uint256 propID = newProposal(proposalDescription, functionsProposalTypes[7]);

        // Get new state update by proposal ID we get from newProposal
        ProposalTypeUpdate storage update = proposalTypeUpdates[propID];
        update.isNewType = true;
        update.newLength = _length;
        update.newRequiredApprovalRate = _requiredApprovalRate;
        update.newRequiredTokenAmount = _requiredTokenAmount;
        update.newRequiredParticipantAmount = _requiredParticipantAmount;
    }

    function executeNewProposalTypeProposal(uint256 _proposalID) public {
        ProposalTypeUpdate storage update = proposalTypeUpdates[_proposalID];

        // It should be NOT executed and a new type
        require(!update.isExecuted && update.isNewType, "Wrong proposal ID");
        
        // Save the staus
        update.status = Status(proposalResult(_proposalID));

        // Check if it is finalized or not
        require(uint256(update.status) > 1, "The proposal still going on or not even started!");

        // if the proposal is approved, apply the update the state
        if (update.status == Status.Approved) {
            proposalTypes.push(
                ProposalType({
                length : update.newLength,
                requiredApprovalRate : update.newRequiredApprovalRate,
                requiredTokenAmount : update.newRequiredTokenAmount,
                requiredParticipantAmount : update.newRequiredParticipantAmount
            }));
        }

        update.isExecuted = true;
    }

    function proposeProposalTypeUpdate(
        uint256 _proposalTypeNumber, 
        uint256 _newLength, 
        uint256 _newRequiredApprovalRate, 
        uint256 _newRequiredTokenAmount, 
        uint256 _newRequiredParticipantAmount
    ) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");

        // Splited the decription to 2 parts, because it was too deep as a whole.
        string memory part1 = string(abi.encodePacked(
            "Updating proposal type number ", Strings.toString(_proposalTypeNumber), " with following parameters: ", 
            "Length to ", Strings.toString(_newLength), " from ", 
            Strings.toString(proposalTypes[_proposalTypeNumber].length), ". ",
            "Required Approval Rate to ", Strings.toString(_newRequiredApprovalRate), " from ", 
            Strings.toString(proposalTypes[_proposalTypeNumber].requiredApprovalRate), ". "
        )); 
        string memory part2 = string(abi.encodePacked(
            "Required Token Amount to ", Strings.toString(_newRequiredTokenAmount), " from ", 
            Strings.toString(proposalTypes[_proposalTypeNumber].requiredTokenAmount), ". ",
            "Required Participant Amount to ", Strings.toString(_newRequiredParticipantAmount), " from ", 
            Strings.toString(proposalTypes[_proposalTypeNumber].requiredParticipantAmount), ". "
        )); 
        string memory proposalDescription = string(abi.encodePacked(part1, part2)); 

        uint256 propID = newProposal(proposalDescription, functionsProposalTypes[7]);

        // Get new state update by proposal ID we get from newProposal
        ProposalTypeUpdate storage update = proposalTypeUpdates[propID];
        update.proposalTypeNumber = _proposalTypeNumber;
        update.newLength = _newLength;
        update.newRequiredApprovalRate = _newRequiredApprovalRate;
        update.newRequiredTokenAmount = _newRequiredTokenAmount;
        update.newRequiredParticipantAmount = _newRequiredParticipantAmount;
    }

    function executeProposalTypeUpdateProposal(uint256 _proposalID) public {
        ProposalTypeUpdate storage update = proposalTypeUpdates[_proposalID];

        // It should be NOT executed and NOT a new type
        require(!update.isExecuted && !update.isNewType, "Wrong proposal ID");
        
        // Save the staus
        update.status = Status(proposalResult(_proposalID));

        // Check if it is finalized or not
        require(uint256(update.status) > 1, "The proposal still going on or not even started!");

        // if the proposal is approved, apply the update the state
        if (update.status == Status.Approved) {
            // Get and Update proposal type
            ProposalType storage propType = proposalTypes[update.proposalTypeNumber];

            propType.length = update.newLength;
            propType.requiredApprovalRate = update.newRequiredApprovalRate;
            propType.requiredTokenAmount = update.newRequiredTokenAmount;
            propType.requiredParticipantAmount = update.newRequiredParticipantAmount;
        }

        update.isExecuted = true;
    }


    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                     Functions as a Tool                      >< >< >< >< >< >< >< >< >< //
    // >< >< >< >< >< >< >< >< ><                                                              >< >< >< >< >< >< >< >< >< //

    receive() external payable {}

    fallback() external payable {}

    /*
     *  @dev Depending on the desired proposal length, there will be required conditions
     *  like approval rate, token amount, participant amount to make that proposal valid.
     *
     *  If there a emergency situation, an urgent proposal with 10 minutes await time
     *  will need higher approval rate to be valid.
     */
    function initializeProposalTypes() internal {        
        proposalTypes.push(         // 0. type TEST: Default value of all proposal functions, make it test purposed for now
            ProposalType({
            length : 1 minutes,
            requiredApprovalRate : 1,
            requiredTokenAmount : 1,
            requiredParticipantAmount : 1
        }));        
        proposalTypes.push(         // 1. type
            ProposalType({
            length : 1 hours,
            requiredApprovalRate : 90,
            requiredTokenAmount : 2000,
            requiredParticipantAmount : 100
        }));        
        proposalTypes.push(         // 2. type
            ProposalType({
            length : 1 days,
            requiredApprovalRate : 80,
            requiredTokenAmount : 3000,
            requiredParticipantAmount : 150
        }));        
        proposalTypes.push(         // 3. type
            ProposalType({
            length : 3 days,
            requiredApprovalRate : 70,
            requiredTokenAmount : 1000,
            requiredParticipantAmount : 50
        }));        
        proposalTypes.push(         // 4. type - Test length
            ProposalType({
            length : 1 minutes,
            requiredApprovalRate : 75,
            requiredTokenAmount : 1,
            requiredParticipantAmount : 1
        }));        
        proposalTypes.push(         // 5. type - Test length
            ProposalType({
            length : 20 seconds,
            requiredApprovalRate : 75,
            requiredTokenAmount : 1,
            requiredParticipantAmount : 1
        }));
        proposalTypes.push(         // x. type - Very Important updates like change in the tokenomics
            ProposalType({
            length : 3 days,
            requiredApprovalRate : 70,
            requiredTokenAmount : 1000,
            requiredParticipantAmount : 50
        }));         
    }
    
    function updateProposalStatus(Proposal storage _proposal) internal {
        require(_proposal.status != Status.NotStarted, 
            "This proposal ID has not been assigned to any proposal bro!"
        );        
        
        // Get current approval rate
        uint256 currentApprovalRate;
        // If there are voter for both side, calculate the rate
        if (_proposal.yayCount > 0 && _proposal.nayCount > 0){
            currentApprovalRate = _proposal.yayCount * 100 / (_proposal.yayCount + _proposal.nayCount);
        }
        // If there is no voter for deny, then the rate is 100%
        else if (_proposal.yayCount > 0 && _proposal.nayCount == 0){
            currentApprovalRate = 100;
        }
        // If there is no voter for approval or both side, then the rate is deafult, which is 0 
        
        for (uint256 i = 0; i < proposalTypes.length; i++){
            // Find the proposal Type
            if (_proposal.proposalType == i){    

                // Change status ONLY IF the time is up
                if (block.timestamp > _proposal.startTime + proposalTypes[i].length){

                    // Finalize it
                    if (proposalTypes[i].requiredParticipantAmount > _proposal.participants ||
                        proposalTypes[i].requiredTokenAmount > _proposal.totalVotes ||
                        proposalTypes[i].requiredApprovalRate > currentApprovalRate
                    ){
                        _proposal.status = Status.Denied;
                    }
                    else {
                        _proposal.status = Status.Approved;
                    }
                }
            }
        }
    }

    function proposalResult(uint256 _proposalID) public returns(uint256) {
        Proposal storage proposal = proposals[_proposalID];
        updateProposalStatus(proposal);
        require (uint256(proposal.status) > 1, "Proposal is still going on or not even started dude!");

        return uint256(proposal.status);
    }

    function isProposalPassed(uint256 _proposalID) public returns(bool) {
        Proposal storage proposal = proposals[_proposalID];
        updateProposalStatus(proposal);
        require (uint256(proposal.status) > 1, "Proposal is still going on or not even started dude!");

        return proposal.status == Status.Approved;
    }

    function finalizeSpendingProposal() public {
        SpendingProposal storage proposal = spendingProposals[spendingProposalCounter.current()];

        require(proposal.status == Status.OnGoing,
            "Dude, there is no monetary proposal to finalize! Are you okay?"
        );
        
        // Update the proposal to check DAO's decision
        Proposal storage DAOproposal = proposals[proposal.proposalID];
        updateProposalStatus(DAOproposal);

        require(uint256(DAOproposal.status) > 1, "The proposal is still going on bro! Come back later!");

        // Write the decision of DAO to the monetary proposal
        proposal.status = DAOproposal.status;
        // Switch to a new proposal
        spendingProposalCounter.increment();
    }

    function merkleCheck(SpendingProposal storage _proposal, bytes32[] calldata _merkleProof) internal returns (uint256) {
        require(!_proposal.claimed[_msgSender()], "Dude! You have already claimed your allowance! Why too aggressive?");

        uint256 allowanceAmount;
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        for (uint256 i = 0; i < _proposal.merkleRoots.length; i++){
            // If the proof valid for this index, get the allowance of this index
            if (MerkleProof.verify(_merkleProof, _proposal.merkleRoots[i], leaf)){
                _proposal.claimed[_msgSender()] = true;
                allowanceAmount = _proposal.allowances[i];
                break;
            }
        }

        return allowanceAmount;
    }

    function returnMerkleRoots(uint256 _spendingProposalNumber) public view returns (bytes32[] memory) {
        return spendingProposals[_spendingProposalNumber].merkleRoots;
    }

    function returnAllowances(uint256 _spendingProposalNumber) public view returns (uint256[] memory) {
        return spendingProposals[_spendingProposalNumber].allowances;
    }

    function getContractCoinBalance() public view returns (uint256){ return address(this).balance; }

    function getContractTokenBalance(address _tokenContractAddress) public returns (uint256) {
        // Checking the balance of DAO in the target token
        bytes memory payload = abi.encodeWithSignature("balanceOf(address)", address(this));
        (bool txSuccess, bytes memory returnData) = _tokenContractAddress.call(payload);
        require(txSuccess, 
            "Balance check transaction failed! Check the address of the target token. It should have balanceOf(address) function!"
        );

        (uint256 DAObalance) = abi.decode(returnData, (uint256));
        return DAObalance;
    }

    function getMinBalanceToPropose() public view returns (uint256) { return minBalanceToPropose; }

}