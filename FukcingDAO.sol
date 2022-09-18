// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


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
    - Gives a voting mechanism for both off-chain and on-chain changes.
    - The Fucking Lords represent 50% of the DAO.

    Jump to line X to see the codes of the DAO.
    The other codes are updated openzepplin contracts to be a non-transferable token.
    We simply removed transfer, approve, allowance functions and events.
*/

/*
 * @author Bora Ozenbirkan
 */
contract FukcingDAO is ERC20, AccessControl {
    using Counters for Counters.Counter;   

    enum ProposalStatus{
        NotStarted, // 0
        OnGoing,    // 1
        Approved,   // 2
        Denied     // 3
    }

    struct ProposalType{
        uint256 lenght;
        uint256 requiredApprovalRate;
        uint256 requiredTokenAmount;
        uint256 requiredParticipantAmount;
    }
    struct Proposal {
        uint256 ID;
        string description;
        uint256 startTime;
        uint256 proposalType;
        ProposalStatus status;
        uint256 participants;
        uint256 totalVotes;
        uint256 yayCount;
        uint256 nayCount;
        mapping (address => bool) isVoted; // Voted EOAs
        mapping (uint256 => bool) isLordVoted; // Voted Lords lordID => true/false
    }
    struct TokenMintProposal {
        ProposalStatus status;
        uint256 proposalID;
        uint256 totalMintAmount;    // Just for information
        bytes32[] addressLists;
        uint256[] allowances;
        mapping (address => bool) claimed;
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant EXECUTER_ROLE = keccak256("EXECUTER_ROLE");
    bytes32 public constant LORD_ROLE = keccak256("LORD_ROLE");
    
    Counters.Counter private proposalCounter;
    Counters.Counter private mintCounter;

    mapping (uint256 => Proposal) public proposals; // proposalID => Proposal
    mapping (uint256 => TokenMintProposal) public tokenMintProposals;

    ProposalType[] public proposalTypes;
    
    address public fukcingLordContract;
    uint256 public minBalanceToPropose;

    constructor() ERC20("FukcingDAO", "FDAO") {
        // The owner starts with a small balance to approve the first mint issuance. 
        // Will change with a new mint approval in the first place to start decentralized.
        _mint(msg.sender, 1024 ether); // Start with 1024 token. 1 for each lord NFT
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(EXECUTER_ROLE, msg.sender);

        initializeProposalTypes();
    }

    /*
     *  @dev Making token non-transferable by overriding all the transfer functions
     *
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
     *  @dev Depending on the desired proposal lenght, there will be required conditions
     *  like approval rate, token amount, participant amount to make that proposal valid.
     *
     *  If there a emergency situation, an urgent proposal with 10 minutes await time
     *  will need higher approval rate to be valid.
     */
    function initializeProposalTypes () internal {
        // 0. type
        proposalTypes.push(
                ProposalType({
                lenght : 10 minutes,
                requiredApprovalRate : 95,
                requiredTokenAmount : 1000,
                requiredParticipantAmount : 50
            })
        );
        // 1. type
        proposalTypes.push(
                ProposalType({
                lenght : 1 hours,
                requiredApprovalRate : 90,
                requiredTokenAmount : 2000,
                requiredParticipantAmount : 100
            })
        );
        // 2. type
        proposalTypes.push(
                ProposalType({
                lenght : 1 days,
                requiredApprovalRate : 80,
                requiredTokenAmount : 3000,
                requiredParticipantAmount : 150
            })
        );
        // 3. type
        proposalTypes.push(
                ProposalType({
                lenght : 3 days,
                requiredApprovalRate : 70,
                requiredTokenAmount : 1000,
                requiredParticipantAmount : 50
            })
        );        
        // 4. type - Test lenght
        proposalTypes.push(
                ProposalType({
                lenght : 3 minutes,
                requiredApprovalRate : 75,
                requiredTokenAmount : 1,
                requiredParticipantAmount : 1
            })
        );
        // 5. type - Test lenght
        proposalTypes.push(
                ProposalType({
                lenght : 20 seconds,
                requiredApprovalRate : 75,
                requiredTokenAmount : 1,
                requiredParticipantAmount : 1
            })
        );        
    }





    // New Proposal method returns the created proposal ID for the caller to track the result
    function newProposal (string memory _description, uint256 _proposalType) public returns(uint256) {
        // Only exetures and the ones who has enough balance to propose can propose
        require(hasRole(EXECUTER_ROLE, _msgSender()) || balanceOf(_msgSender()) > minBalanceToPropose, "You don't have enough voting power to propose");
        require(_proposalType >= 0 && _proposalType < proposalTypes.length, "Invalid proposal type!");

        // Start with the current empty proposal
        Proposal storage newProposal = proposals[proposalCounter.current()];

        newProposal.ID = proposalCounter.current();
        proposalCounter.increment();

        newProposal.description = _description;
        newProposal.startTime = block.timestamp;
        newProposal.proposalType = _proposalType;
        newProposal.status = ProposalStatus.OnGoing;        

        return newProposal.ID; // return the current proposal ID
    }
    function vote (uint256 _proposalID, bool _isApproving) public {
        // Caller needs at least 1 token to vote!
        require(balanceOf(_msgSender()) >= 1 ether, "You don't have enoguh voting power!");

        Proposal storage proposal = proposals[_proposalID]; 
        updateProposalStatus(proposal);

        require(proposal.status == ProposalStatus.OnGoing, "The proposal has ended!");
        require(proposal.isVoted[_msgSender()] == false, "You already voted!");

        proposal.isVoted[_msgSender()] = true;

        // Removing decimals (1 ether) to avoid unnecessarily large numbers.
        uint256 votingPower = balanceOf(_msgSender()) / 1 ether;

        if (_isApproving){
            proposal.yayCount += votingPower;
        }
        else {    
            proposal.nayCount += votingPower;
        }
                
        proposal.participants++;
        proposal.totalVotes += votingPower;
    }
    /*
     *  @dev Only the Fukcing Lord Contract can call this function to vote.
     */
    function lordVote(uint256 _proposalID, bool _isApproving, uint256 _lordID, uint256 _lordTotalSupply) public onlyRole(LORD_ROLE) {
        Proposal storage proposal = proposals[_proposalID]; 
        updateProposalStatus(proposal);

        require(proposal.status == ProposalStatus.OnGoing, "The proposal has ended!");
        require(proposal.isLordVoted[_lordID] == false, "This lord already voted!");

        proposal.isLordVoted[_lordID] = true;
        
        // Get the voting power of the lord: 
        // Lord voting power (aka. 50% of total supply of FDAO token) / lord total supply
        // Removing decimals (1 ether) to avoid unnecessarily large numbers.
        uint256 votingPower = balanceOf(fukcingLordContract) / _lordTotalSupply / 1 ether;

        if (_isApproving){
            proposal.yayCount += votingPower;
        }
        else {    
            proposal.nayCount += votingPower;
        }
                
        proposal.participants++;
        proposal.totalVotes += votingPower;        
    }

    function proposalResult (uint256 _proposalID) public returns(uint256) {
        Proposal storage proposal = proposals[_proposalID];
        updateProposalStatus(proposal);
        require (uint256(proposal.status) > 1, "Proposal is still going on or not even started!");

        return uint256(proposal.status);
    }
    function isProposalPassed (uint256 _proposalID) public returns(bool) {
        Proposal storage proposal = proposals[_proposalID];
        updateProposalStatus(proposal);
        require (uint256(proposal.status) > 1, "Proposal is still going on or not even started!");

        return proposal.status == ProposalStatus.Approved;
    }






    function issueNewTokens (
        bytes32[] memory _addressLists, 
        uint256[] memory _allowances, 
        uint256 _totalMintAmount
    ) public onlyRole(EXECUTER_ROLE) {
        TokenMintProposal storage newTokenProposal = tokenMintProposals[mintCounter.current()];

        require(newTokenProposal.status == ProposalStatus.NotStarted,
            "The current mint proposal is not finalized yet!"
        );

        newTokenProposal.status = ProposalStatus.OnGoing;
        newTokenProposal.totalMintAmount = _totalMintAmount;
        newTokenProposal.addressLists = _addressLists;
        newTokenProposal.allowances = _allowances;

        string memory proposalDescription = 
            string(abi.encodePacked("Minting ", Strings.toString(_totalMintAmount), " new FDAO tokens."));

        // TEST -> choosing shortest lenght. Change it to 3 days (type 3) before mainnet launch
        
        newTokenProposal.proposalID = newProposal(proposalDescription, 5);
    }
    function finalizeTokenProposal() public {
        TokenMintProposal storage tokenProposal = tokenMintProposals[mintCounter.current()];

        require(tokenProposal.status == ProposalStatus.OnGoing,
            "There is no token proposal for new token issuance!"
        );
        
        // Update the proposal to check DAO's decision
        Proposal storage DAOproposal = proposals[tokenProposal.proposalID];
        updateProposalStatus(DAOproposal);

        require(uint256(DAOproposal.status) > 1, "The proposal is still going on! Come back later!");

        // Write the decition of DAO to the token proposal
        tokenProposal.status = DAOproposal.status;
        // Switch to a new proposal
        mintCounter.increment();
    }
    function claimToken(
        uint256 _mintProposalNumber, 
        bytes32[] calldata _merkleProof
    ) public onlyRole(EXECUTER_ROLE) {
        TokenMintProposal storage tokenProposal = tokenMintProposals[_mintProposalNumber];

        require(tokenProposal.status == ProposalStatus.Approved,
            "The proposal didn't pass. Check your mint proposal number!"
        );
        
        uint256 allowanceAmount = merkleCheck(tokenProposal, _merkleProof);
        require(allowanceAmount > 0, "You don't have any allowance!");        

        // TEST -> if the merkleCheck doesn't make it true, you make it. tokenProposal.claimed[_msgSender()] = true;
        _mint(_msgSender(), allowanceAmount);
    }

    function merkleCheck (
        TokenMintProposal storage _tokenProposal, 
        bytes32[] calldata _merkleProof
    ) internal returns (uint256) {
        uint256 allowanceAmount;
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        if (_tokenProposal.claimed[_msgSender()] == false){

            for (uint256 i = 0; i < _tokenProposal.addressLists.length; i++){

                // If the proof valid for this index, get the allowance of this index
                if (MerkleProof.verify(_merkleProof, _tokenProposal.addressLists[i], leaf)){
                    _tokenProposal.claimed[_msgSender()] = true;
                    allowanceAmount = _tokenProposal.allowances[i];
                    break;
                }
            }
        }
        else { // if address already has a allowance record
            revert("You have already claimed your allowance!");
        }

        return allowanceAmount;
    }



    // Add spending functions for FUKC token

    // Add spending functions for Native coin





    function modifyProposalType (
        uint256 _proposalTypeNumber, uint256 _lenght, uint256 _requiredApprovalRate, 
        uint256 _requiredTokenAmount, uint256 _requiredParticipantAmount)
        public {
        
            /*
                Change mechanism goes here
            */
    }

    function updateProposalStatus(Proposal storage _proposal) internal {
        require(_proposal.status != ProposalStatus.NotStarted, 
            "This proposal ID has not been assigned to any proposal yet!"
        );        
        
        // Get current approval rate
        uint256 currentApprovalRate;
        if (_proposal.yayCount > 0 && _proposal.nayCount > 0){
            currentApprovalRate = _proposal.yayCount * 100 / (_proposal.yayCount + _proposal.nayCount);
        }
        else if (_proposal.yayCount > 0 && _proposal.nayCount == 0){
            currentApprovalRate = 100;
        }
        
        for (uint256 i = 0; i < proposalTypes.length; i++){
            // Find the proposal Type
            if (_proposal.proposalType == i){    

                // Change status ONLY IF the time is up
                if (block.timestamp > _proposal.startTime + proposalTypes[i].lenght){

                    // Finalize it
                    if (proposalTypes[i].requiredParticipantAmount > _proposal.participants ||
                        proposalTypes[i].requiredTokenAmount > _proposal.totalVotes ||
                        proposalTypes[i].requiredApprovalRate > currentApprovalRate
                    ){
                        _proposal.status = ProposalStatus.Denied;
                    }
                    else {
                        _proposal.status = ProposalStatus.Approved;
                    }
                }
            }
        }
    }

    function updateFukcingLordContractAddress (address _newAddress) public onlyRole(EXECUTER_ROLE) {

    } 
    function updateMinBalanceToPropose (uint256 _newAmount) public onlyRole(EXECUTER_ROLE) {

    } 
    
}