// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
  * -> DAO can give point to clans as well !!
  * -> Add non renandant modifiers to functions
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
                                                                                                         
                                                                                                                                                                   
`7MM"""YMM           `7MM               db                           `7MM"""Yb.      db       .g8""8q.   
  MM    `7             MM                                              MM    `Yb.   ;MM:    .dP'    `YM. 
  MM   d `7MM  `7MM    MM  ,MP',p6"bo `7MM  `7MMpMMMb.  .P"Ybmmm       MM     `Mb  ,V^MM.   dM'      `MM 
  MM""MM   MM    MM    MM ;Y  6M'  OO   MM    MM    MM :MI  I8         MM      MM ,M  `MM   MM        MM 
  MM   Y   MM    MM    MM;Mm  8M        MM    MM    MM  WmmmP"         MM     ,MP AbmmmqMA  MM.      ,MP 
  MM       MM    MM    MM `Mb.YM.    ,  MM    MM    MM 8M              MM    ,dP'A'     VML `Mb.    ,dP' 
.JMML.     `Mbod"YML..JMML. YA.YMbmd' .JMML..JMML  JMML.YMMMMMb      .JMMmmmdP'.AMA.   .AMMA. `"bmmd"'   
                                                       6'     dP                                         
                                                       Ybmmmd'                                                                                 


*/

/*
    We are the FukcingDAO. We make our changes as possible as on-chain and fair!

    The Fukcing DAO tokens are not transferable!
    Therefore you can't buy them, you have to earn them!
    FDAO token is based on ERC-20 standard and manipulated to be non-transferable.

    What does DAO do?
    - Issues new FDAO tokens.
    - Approves all economic changes in WeFukc.
    - Provides a on-chain voting mechanism for both off-chain and on-chain changes.
    - The Fucking Lords represent 50% of the DAO.

    Jump to line X to see the codes of the DAO.
    The other codes are updated openzepplin contracts to be a non-transferable token.
    We simply removed transfer, approve, allowance functions and events.

    Only 1 monetary proposal can be active at a time! Therefore, you need to wait for
    the current one to finalize to propose a new monetary proposal. There are 3 different
    monetary proposals: FDAO token mint, FUKC token spending, Native Coin Spending.

    DAO will decide how to spend its treasury with monetary proposals.
*/

/*
 * @author Bora
 */
contract FukcingDAO is ERC20 {
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

    struct MonetaryProposal {
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
     * proposalTypes's Indexes with corresponding meaning
     *  
     * Index 0: Less important proposals
     * Index 1: Moderately important proposals
     * Index 2: Highly important proposals
     * Index 3: MAX SUPPLY CHANGE PROPOSAL
     */
    uint256[4] public proposalTypeIndexes;

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
    
    Counters.Counter private proposalCounter;
    Counters.Counter private monetaryProposalCounter;

    mapping(uint256 => Proposal) public proposals; // proposalID => Proposal
    mapping(uint256 => ProposalTracker) public proposalTrackers; // proposalID => Proposal Tracker
    mapping(uint256 => MonetaryProposal) public monetaryProposals;
    mapping(uint256 => ProposalTypeUpdate) public proposalTypeUpdates;  // proposalTypeUpdateID => ProposalTypeUpdate

    ProposalType[] public proposalTypes;

    uint256 public minBalanceToPropose;     // Amount of tokens without decimals

    constructor() ERC20("FukcingDAO", "FDAO") {
        /*
         * The contract creator starts with the smallest balance (0.0000000000000000001 token) to approve the first mint. 
         * First proposal will be mint of 666 tokens to be distributed amoung the community (50%) and the team (50%).
         * The team will get maximum of 5% in the following mint proposals to give the control to the community.
        **/
        _mint(_msgSender(), 1);

        // Initial settings
        initializeProposalTypes();
        minBalanceToPropose = 666 ether; // 666 tokens needed as a initial value

        // Start with index of 1 to avoid some double propose in state updates
        proposalCounter.increment(); 
    }
    // Events: event NewProposal(x, y); CapitalizedWords
/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><               Making The Token Non-Transferable              >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/
    /*
     *  @dev Making token non-transferable by overriding all the transfer functions
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
/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><                       Proposal Mechanism                     >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/
    /* 
     * @dev New Proposal method returns the created proposal ID for the caller to track the result
     * To finalize a proposal, check the proposal result with isProposalPassed or proposalResult functions.
     */
    function newProposal(string memory _description, uint256 _proposalType) public returns(uint256) {
        // Only exetures and the ones who has enough balance to propose can propose
        require(_msgSender() == contracts[5] || balanceOf(_msgSender()) >= minBalanceToPropose, 
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
        require(proposal.isVoted[_msgSender()] == false, "You have already voted dude! Why too aggressive?");

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
     *  @dev Only the Fukcing Lord Contract can call this function to vote.
     */
    function lordVote(uint256 _proposalID, bool _isApproving, uint256 _lordID, uint256 _lordTotalSupply) 
    public returns (string memory) {
        require(_msgSender() == contracts[7], "Only the Lords can call this function! Go away, you prick!");

        Proposal storage proposal = proposals[_proposalID]; 
        updateProposalStatus(proposal);

        require(proposal.status == Status.OnGoing, "The proposal has ended my lord!");
        require(proposal.isLordVoted[_lordID] == false, "My lord, you have already voted!");

        proposal.isLordVoted[_lordID] = true;
        
        // Get the voting power of the lord: 
        // Lord voting power (aka. 50% of total supply of FDAO token) / lord total supply
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
/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><                      Monetary Executions                     >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/    
    // New FDAO token mint
    function proposeNewMint(bytes32[] memory _merkleRoots, uint256[] memory _allowances, uint256 _totalMintAmount) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        
        MonetaryProposal storage proposal = monetaryProposals[monetaryProposalCounter.current()];        
        require(proposal.status == Status.NotStarted, "The current monetary proposal is not finalized bro! Come back later.");

        proposal.status = Status.OnGoing;
        proposal.amount = _totalMintAmount;
        proposal.merkleRoots = _merkleRoots;
        proposal.allowances = _allowances;

        string memory proposalDescription = string(abi.encodePacked(
            "Minting ", Strings.toString(_totalMintAmount), " new FDAO tokens."
        ));

        proposal.proposalID = newProposal(proposalDescription, proposalTypeIndexes[1]);
    }

    function mintTokens(uint256 _monetaryProposalNumber, bytes32[] calldata _merkleProof) public {
        MonetaryProposal storage proposal = monetaryProposals[_monetaryProposalNumber];

        require(proposal.status == Status.Approved,
            "This proposal didn't pass or not finalized bro! Check your monetary proposal number!"
        );
        
        uint256 allowanceAmount = merkleCheck(proposal, _merkleProof);
        require(allowanceAmount > 0, "You don't have any allowance, sorry dude!");      
        require(allowanceAmount + proposal.totalClaimedAmount <= proposal.amount, "The approved amount exceeding!");  

        // Mint for the caller.
        _mint(_msgSender(), allowanceAmount);
        // Lords don't mint tokens themselves. Therefore, everyone mints for them as many as they mint for themselves.
        // And this is how Lords hold 50% of the balance and represent 50% of the DAO.
        _mint(contracts[7], allowanceAmount);   

        proposal.totalClaimedAmount += allowanceAmount;
    }

    // DAO Token Spendings
    function proposeNewTokenSpending(
        address _tokenContractAddress, 
        bytes32[] memory _merkleRoots, 
        uint256[] memory _allowances, 
        uint256 _totalSpending
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

        // First of all, create a new monetary proposal and check the current slot is empty for a new one.
        MonetaryProposal storage proposal = monetaryProposals[monetaryProposalCounter.current()];
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
        
        proposal.proposalID = newProposal(proposalDescription, proposalTypeIndexes[1]);
    }

    function claimTokenSpending(uint256 _monetaryProposalNumber, bytes32[] calldata _merkleProof) public {
        MonetaryProposal storage proposal = monetaryProposals[_monetaryProposalNumber];

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
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        require(address(this).balance >= _totalSpending, "DAO has not enough balance to spend! Sad, isn't it?");

        // Create a new monetary proposal and check the current slot is empty for a new one.
        MonetaryProposal storage proposal = monetaryProposals[monetaryProposalCounter.current()];
        require(proposal.status == Status.NotStarted, "The current monetary proposal is not finalized bro! Come back later.");

        proposal.status = Status.OnGoing;
        proposal.amount = _totalSpending;
        proposal.merkleRoots = _merkleRoots;
        proposal.allowances = _allowances;

        string memory proposalDescription = string(abi.encodePacked("Spending of ", Strings.toString(_totalSpending), " coins"));
        
        proposal.proposalID = newProposal(proposalDescription, proposalTypeIndexes[1]);
    }

    function claimCoinSpending(uint256 _monetaryProposalNumber, bytes32[] calldata _merkleProof) public {
        MonetaryProposal storage proposal = monetaryProposals[_monetaryProposalNumber];

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
/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><                    Updating State Variables                  >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/
    /**
     * Updates by DAO - Update Codes - Not required for monetaryUpdates and proposalTypeUpdates
     *
     * Contract Address Change -> Code: 1
     * Proposal Type Index Change -> Code: 2
     * minBalanceToProp -> Code: 3
     * 
     */

    function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
            "New address can not be the null or same address!"
        );

        string memory proposalDescription = string(abi.encodePacked(
        "In Fukcing DAO contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
            Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
        )); 

        // Create a new proposal - proposal type Index : 2 - Highly Important
        uint256 propID = newProposal(proposalDescription, proposalTypeIndexes[2]);

        // Save data to the proposal
        proposalTrackers[propID].updateCode = 1;
        proposalTrackers[propID].index = _contractIndex;
        proposalTrackers[propID].newAddress = _newAddress;
    }

    function executeContractAddressUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 1, "Wrong proposal ID");
        require(proposal.isExecuted == false, "Wrong proposal ID");
        
        // Save the staus
        proposal.status = Status(proposalResult(_proposalID));

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if approved, apply the update the state
        if (proposal.status == Status.Approved)
            contracts[proposal.index] = proposal.newAddress;

        proposal.isExecuted = true;
    }

    function updateProposalTypeIndex(uint256 _proposalIndex, uint256 _newType) public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        require(_newType != proposalTypeIndexes[_proposalIndex], "Proposal Types are already the same moron, check your input!");
        require(_proposalIndex != 0, "0 index of proposalTypes is not in service. No need to update!");

        string memory proposalDescription = string(abi.encodePacked(
        "In Fukcing DAO contract, Updating proposal type indexes of index ", Strings.toHexString(_proposalIndex), " to ", 
            Strings.toHexString(_newType), " from ", Strings.toHexString(proposalTypeIndexes[_proposalIndex]), "."
        )); 

        // Create a new proposal - proposal type Index : 2 - Highly Important
        uint256 propID = newProposal(proposalDescription, proposalTypeIndexes[2]);

        // Get data to the proposal
        proposalTrackers[propID].updateCode = 2;
        proposalTrackers[propID].index = _proposalIndex;
        proposalTrackers[propID].newUint = _newType;
    }

    function executeProposalTypeIndexUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 2, "Wrong proposal ID");
        require(proposal.isExecuted == false, "Wrong proposal ID");

        // Save the staus
        proposal.status = Status(proposalResult(_proposalID));

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            proposalTypeIndexes[proposal.index] = proposal.newUint;

        proposal.isExecuted = true;
    }    

    function proposeMinBalanceToPropUpdate(uint256 _newAmount) public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

        string memory proposalDescription = string(abi.encodePacked(
            "In Fukcing DAO contract, updating Minimum Balance To Propose to ", 
            Strings.toHexString(_newAmount), " from ", Strings.toHexString(minBalanceToPropose), "."
        )); 

        // Create a new proposal- proposal type Index : 2 - Highly Important
        uint256 propID = newProposal(proposalDescription, proposalTypeIndexes[2]);

        // Save data to the local proposal
        proposalTrackers[propID].updateCode = 3;
        proposalTrackers[propID].newUint = _newAmount;
    }

    function executeMinBalanceToPropUpdateProposal(uint256 _proposalID) public {
        ProposalTracker storage proposal = proposalTrackers[_proposalID];

        require(proposal.updateCode == 3, "Wrong proposal ID");
        require(proposal.isExecuted == false, "Wrong proposal ID");
        
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
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

        string memory proposalDescription = string(abi.encodePacked(
            "Adding a new proposal type with following parameters: ", 
            "Length of ", Strings.toString(_length), ". ",
            "Required Approval Rate of ", Strings.toString(_requiredApprovalRate), ". ",
            "Required Token Amount of ", Strings.toString(_requiredTokenAmount), ". ",
            "Required Participant Amount of ", Strings.toString(_requiredParticipantAmount), "."
        ));

        uint256 propID = newProposal(proposalDescription, proposalTypeIndexes[1]);

        // Get new state update by proposal ID we get from newProposal
        ProposalTypeUpdate storage update = proposalTypeUpdates[propID];
        update.newLength = _length;
        update.newRequiredApprovalRate = _requiredApprovalRate;
        update.newRequiredTokenAmount = _requiredTokenAmount;
        update.newRequiredParticipantAmount = _requiredParticipantAmount;
    }

    function executeNewProposalTypeProposal(uint256 _proposalID) public {
        ProposalTypeUpdate storage update = proposalTypeUpdates[_proposalID];

        require(update.isExecuted == false, "Wrong proposal ID");
        
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
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

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

        uint256 propID = newProposal(proposalDescription, proposalTypeIndexes[2]);

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

        require(update.isExecuted == false, "Wrong proposal ID");
        
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

/*  
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< ><                     Functions as a Tool                      >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< ><                                            >< >< >< >< >< >< >< >< >< >< >< >< ><
    >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><  >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< 
*/  
    receive() external payable {}

    /*
     *  @dev Depending on the desired proposal length, there will be required conditions
     *  like approval rate, token amount, participant amount to make that proposal valid.
     *
     *  If there a emergency situation, an urgent proposal with 10 minutes await time
     *  will need higher approval rate to be valid.
     */
    function initializeProposalTypes() internal {        
        proposalTypes.push(         // 0. type
            ProposalType({
            length : 10 minutes,
            requiredApprovalRate : 95,
            requiredTokenAmount : 1000,
            requiredParticipantAmount : 50
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

    function finalizeMonetaryProposal() public {
        MonetaryProposal storage proposal = monetaryProposals[monetaryProposalCounter.current()];

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
        monetaryProposalCounter.increment();
    }

    function merkleCheck(MonetaryProposal storage _proposal, bytes32[] calldata _merkleProof) internal returns (uint256) {
        require(_proposal.claimed[_msgSender()] == false, "Dude! You have already claimed your allowance! Why too aggressive?");

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

    function returnMerkleRoots(uint256 _monetaryProposalNumber) public view returns (bytes32[] memory) {
        return monetaryProposals[_monetaryProposalNumber].merkleRoots;
    }

    function returnAllowances(uint256 _monetaryProposalNumber) public view returns (uint256[] memory) {
        return monetaryProposals[_monetaryProposalNumber].allowances;
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