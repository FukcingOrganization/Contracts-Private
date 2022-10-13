// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract FukcingRent {

  address fukcingLord;
  address fukcingToken;

  constructor (address _lordContract, address _tokenContract) {
    fukcingLord = _lordContract;
    fukcingToken = _tokenContract;
  }

  function rent(uint256 _lordID, address _user, uint256 _expires) public {
    // Get money
    

    // Rent the NFT
    bytes memory payload = abi.encodeWithSignature("setUser(uint256,address,uint256)", _lordID, _user, _expires);
    (bool txSuccess, ) = fukcingLord.call(payload);
    require(txSuccess, "Transaction has fail to set rent from the Fukcing Lord contract!");
  }
}