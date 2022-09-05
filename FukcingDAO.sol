// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

/*


                                ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣉⣉⠉⠻⠿⠿⠇⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⢠⣤⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⡄⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠸⢿⣿⣿⡿⠿⢿⣿⣿⡿⠿⢿⣿⣿⡿⠇⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀
                                ⠀⠀⠀⠀⠀⠀⠸⠿⠿⠀⠀⠸⠿⠿⠇⠀⠀⠿⠿⠇⠀⠀⠀⠀⠀⠀
                                ⢠⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡄
                                ⢸⣿⣿⣿⡿⠿⢿⣿⣿⠿⠿⢿⣿⣿⡿⠿⠿⣿⣿⡿⠿⢿⣿⣿⣿⡇
                                ⢸⣿⣿⣿⡇⠀⢸⣿⣿⠀⠀ ⢸⣿⣿⡇⠀ ⣿⣿⡇  ⢸⣿⣿⣿⡇
                                ⢸⣿⣿⣿⣧⣤⣼⣿⣿⣤⣤⣼⣿⣿⣧⣤⣤⣿⣿⣧⣤⣼⣿⣿⣿⡇
                                ⠀⠛⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠛⠀                                                         
                      
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

/**
 * @dev Interface of the Fukcing DAO.
 */
interface IFDAO {
    function propose(string memory _decription) external returns (bool);
    
    function vote(uint256 _proposalID, bool _isVotingFor) external returns (bool);
    
    function lordVote(uint256 _proposalID, bool _isVotingFor) external returns (bool);
    
    function newMint() external returns (bool);
    
    function proposalResult(uint256 _proposalID) external returns (bool);
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
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
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
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("FukcingDAO", "FDAO") {
        _mint(msg.sender, 100 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function propose(string memory _decription) public virtual override  returns (bool){
        return true;
    }
    
    function vote(uint256 _proposalID, bool _isVotingFor) public virtual override  returns (bool){
        return true;
    }
    
    function lordVote(uint256 _proposalID, bool _isVotingFor) public virtual override  returns (bool){
        return true;
    }
    
    function newMint() public virtual override  returns (bool){
        return true;
    }
    
    function proposalResult(uint256 _proposalID) public virtual override  returns (bool){
        return true;
    }
}

// Psudo code of FuckingDAO (FDAO) contract

// Remove all the transfer methods by overriding them with an empty method or copy past the other methods from the base contract



/*

// Proposal structure
Struct Proposal{
  uint256 ID;
  string description;
  uint256 yayCount;
  uint256 nayCount;
  timeUnit startTime;
  timeUnit lenght;
  mapping (address voter => bool isVoted) isVoted;
}

Counter proposalCounter;

uint256 minBalanceToPropose

mapping (uint256 proposalID => struct Proposal) proposals

// Access Modifiers

// mint new tokens
  // Propose new mint
  // Mint on result


// claim tokens
  // EOA claim
  // Lord claim


// Voting mechanism
// New Proposal method returns the created proposal ID for the caller to track the result
function newProposal (string storage _description, timeUnit storage _lenght) public returns(uint256) {
  require(owner || balances[sender] > minBalanceToPropose, "You don't have enough voting power to propose");

  // create new proposal
  newProposal.ID = proposalCounter;
  proposalCounter.increment;
  newProposal.description = _description;
  newProposal.startTime = now;
  newProposal.lenght = _lenght;

  // Write the proposal to the mapping
  Proposals[newProposal.ID] = newProposal;

  return proposalCounter - 1; // return the current proposal ID
}

function voteForProposal (uint256 _proposalID, bool isApproving) public {
  require(balances[sender] > 0, "You don't have any voting power!");

  Proposal storage proposal = proposals[_proposalID]; 

  require(proposal.isVoted[sender] == false, "You already voted!");
  require(proposal.startTime + proposal.lenght < now, "Proposal time has expired!");

  proposal.isVoted[sender] = true;

  if (isApproving){
    proposal.yayCount += balances[sender];
  }
  else {    
    proposal.nayCount += balances[sender];
  }
}

function descriptionOfProposal (uint256 _proposalID) view public returns(String){
  return proposals[_proposalID].description;
}

function resultOfProposal (uint256 _proposalID) view public returns(bool){
  Proposal proposal = proposals[_proposalID];
  require (proposal.startTime + proposal.lenght > now, "Proposal is still going on!");

  return proposal.yayCounts > proposal.nayCounts;
}


















*/