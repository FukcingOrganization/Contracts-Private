// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
  * -> Based on ERC-721
  * -> Not: Now its non transferable, check token URI set.
  * -> Can't be owned or transferred, they just can be minted by everyone
  * -> Has name, normal image and fukced image, numOfFukced
  * -> minter can change the URI of the images
  * -> No max supply, keep total supply
  * -> Update: DAO and Executer add, UpdatePropType, Mint Cost
  */

/*
 * @author Bora
 */


contract FukcingBoss is ERC721, ERC721URIStorage, ERC721Burnable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  address fukcingExecutors;
  IERC20 fukcingDAO;
  IERC20 fukcingToken;
  IERC721 fukcingBoss;

  uint256 public totalSupply;
  uint256 public mintCost;

  constructor() ERC721("FukcingBoss", "FBOSS") {}

  function safeMint(address to, string memory uri) public {
    (bool txSuccess, ) = address(fukcingToken).call(abi.encodeWithSignature("burn(uint256)", mintCost));
    require(txSuccess, "Mint tx has failed!");

    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    totalSupply++;
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    totalSupply--;
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
    return super.tokenURI(tokenId);
  }
  /*
   *  @dev Making token non-transferable by overriding all the transfer functions
   */
  function approve(address spender, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function setApprovalForAll(address operator, bool approved) public virtual override {
    revert("This is a non-transferable token!");
  }
    
  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
    revert("This is a non-transferable token!");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
    revert("This is a non-transferable token!");
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
    require(ownerOf(tokenId) == _msgSender(), "Only the owner can change the URI!");
    _setTokenURI(tokenId, _tokenURI);
  }

}
