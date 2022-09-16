// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


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

/**
 * @dev Interface of the Fukcing DAO.
 */
interface IFDAO {
    /*
    function propose(string memory _decription) external;
    
    function vote(uint256 _proposalID, bool _isVotingFor) external;
    
    function lordVote(uint256 _proposalID, bool _isVotingFor) external;
    
    function newMint() external;

    function claimToken(uint256 _mintProposalID) external;
    
    function proposalResult(uint256 _proposalID) external returns (bool);
    */
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. 
    Removed transfer, approve, allowance functions and events.
 */
interface IERC20 {

    /**
     * @dev Removed transfer, approve, allowance functions and events.
     */

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {

    /**
     * @dev Removed transfer, approve, allowance functions and events.        
    */


    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        _afterTokenTransfer(account, address(0), amount);
    }


    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract FukcingDAO is ERC20, AccessControl, IFDAO {
    using Counters for Counters.Counter;   

    enum ProposalStatus{
        NotStarted,
        OnGoing,
        Approved,
        Denied,
        NotValid
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

    /*
        @dev Depending on the desired proposal lenght, there will be required conditions
        like approval rate, token amount, participant amount to make that proposal valid.

        If there a emergency situation, an urgent proposal with 10 minutes await time
        will need higher approval rate to be valid.
    */
    ProposalType[] proposalTypes = [
        ProposalType({
            lenght : 10 minutes,
            requiredApprovalRate : 95,
            requiredTokenAmount : 1000 ether,
            requiredParticipantAmount : 50
        }),
        ProposalType({
            lenght : 1 hours,
            requiredApprovalRate : 90,
            requiredTokenAmount : 2000 ether,
            requiredParticipantAmount : 100
        }),
        ProposalType({
            lenght : 1 days,
            requiredApprovalRate : 80,
            requiredTokenAmount : 3000 ether,
            requiredParticipantAmount : 150
        }),
        ProposalType({
            lenght : 3 days,
            requiredApprovalRate : 70,
            requiredTokenAmount : 1000 ether,
            requiredParticipantAmount : 50
        }),
        // Test lenght
        ProposalType({
            lenght : 3 minutes,
            requiredApprovalRate : 75,
            requiredTokenAmount : 1 ether,
            requiredParticipantAmount : 1
        })
    ];   
 
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant EXECUTER_ROLE = keccak256("EXECUTER_ROLE");
    bytes32 public constant LORD_ROLE = keccak256("LORD_ROLE");
    
    mapping (uint256 => Proposal) public proposals; // proposalID => Proposal

    Counters.Counter private proposalCounter;

    address public fukcingLordContract;
    uint256 public minBalanceToPropose;

    constructor() ERC20("FukcingDAO", "FDAO") {
        // The owner starts with a small balance to approve the first mint issuance. 
        // Will change with a new mint approval in the first place to start decentralized.
        _mint(msg.sender, 1024 ether); // Start with 1024 token. 1 for each lord NFT
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(EXECUTER_ROLE, msg.sender);
    }

    // Will be entegrated to the new mint funtion
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // New Proposal method returns the created proposal ID for the caller to track the result
    function newProposal (string memory _description, uint256 _proposalType) public returns(uint256) {
        // Only exetures and the ones who has enough balance to propose can propose
        require(hasRole(EXECUTER_ROLE, _msgSender()) || balanceOf(_msgSender()) > minBalanceToPropose, "You don't have enough voting power to propose");
        require(_proposalType > 0 && _proposalType < proposalTypes.length, "Invalid proposal type!");

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
        require(balanceOf(_msgSender()) > 0, "You don't have any voting power!");

        updateProposalStatus(_proposalID);
        Proposal storage currentProposal = proposals[_proposalID]; 

        require(currentProposal.status == ProposalStatus.OnGoing, "The proposal has ended!");
        require(currentProposal.isVoted[_msgSender()] == false, "You already voted!");

        currentProposal.isVoted[_msgSender()] = true;

        if (_isApproving){
            currentProposal.yayCount += balanceOf(_msgSender());
        }
        else {    
            currentProposal.nayCount += balanceOf(_msgSender());
        }
                
        currentProposal.participants++;
        currentProposal.totalVotes += balanceOf(_msgSender());
    }

    /*
        @dev Only the Fukcing Lord Contract can call this function to vote.
    */
    function lordVote(uint256 _proposalID, bool _isApproving, uint256 _lordID, uint256 _lordTotalSupply) public onlyRole(LORD_ROLE) {
        updateProposalStatus(_proposalID);
        Proposal storage currentProposal = proposals[_proposalID]; 

        require(currentProposal.status == ProposalStatus.OnGoing, "The proposal has ended!");
        require(currentProposal.isLordVoted[_lordID] == false, "This lord already voted!");

        currentProposal.isLordVoted[_lordID] = true;
        // Get the voting power of the lord: 
        // Lord voting power (aka. 50% of total supply of FDAO token) / lord total supply
        uint256 votingPower = balanceOf(fukcingLordContract) / _lordTotalSupply;

        if (_isApproving){
            currentProposal.yayCount += votingPower;
        }
        else {    
            currentProposal.nayCount += votingPower;
        }
                
        currentProposal.participants++;
        currentProposal.totalVotes += votingPower;        
    }

    function descriptionOfProposal (uint256 _proposalID) view public returns(string memory){
        return proposals[_proposalID].description;
    }

    function resultOfProposal (uint256 _proposalID) view public returns(uint256){
        Proposal storage prop = proposals[_proposalID];
        require (uint256(prop.status) <= 1, "Proposal is still going on or not even started!");

        return uint256(prop.status);
    }
    
    
    
    function proposalResult(uint256 _proposalID) public returns (bool){
        return true;
    }    
    
    function newMint() public {
        // Check 

    }

    function claimToken(uint256 _mintProposalID) public {
        // Check the mintproposalID
        // If there is a allowance, transfer the balance 
        // If no, revert
    }

    function modifyProposalType (
        uint256 _proposalTypeNumber, uint256 _lenght, uint256 _requiredApprovalRate, 
        uint256 _requiredTokenAmount, uint256 _requiredParticipantAmount)
        public {
        
            /*
                Change mechanism goes here
            */
    }

    function updateProposalStatus(uint256 _proposalID) internal {
        require(proposals[_proposalID].status != ProposalStatus.NotStarted, 
            "This proposal ID has not been assigned to any proposal yet!");

        Proposal storage propToUpdate = proposals[_proposalID];
        uint256 currentApprovalRate = 
            propToUpdate.yayCount * 100 / propToUpdate.yayCount + propToUpdate.nayCount;

        // Find the proposal Type
        for (uint256 i = 0; i < proposalTypes.length; i++){
            if (propToUpdate.proposalType == i){
                // Change status ONLY IF the time is up
                if (propToUpdate.startTime + proposalTypes[i].lenght > block.timestamp){
                    // Check if it is valid
                    if (proposalTypes[i].requiredParticipantAmount > propToUpdate.participants) {
                        propToUpdate.status = ProposalStatus.NotValid;
                    }
                    else if (proposalTypes[i].requiredTokenAmount > propToUpdate.totalVotes) {
                        propToUpdate.status = ProposalStatus.NotValid;
                    }
                    // Check if approved or denied by DAO
                    else if (proposalTypes[i].requiredApprovalRate > currentApprovalRate) {
                        propToUpdate.status = ProposalStatus.Denied;
                    }
                    else {
                        propToUpdate.status = ProposalStatus.Approved;
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