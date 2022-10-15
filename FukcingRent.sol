// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract FukcingRent {

  address fukcingDAO;
  address fukcingExecutors;
  address fukcingLord;
  address fukcingToken;

  uint256 burnRate;

  constructor (address _lordContract, address _tokenContract) {
    fukcingLord = _lordContract;
    fukcingToken = _tokenContract;
    burnRate = 13;
  }

  function rent(uint256 _lordID, address _lordAddress, uint256 _rentFee, address _user, uint256 _expires) public {
    // Burn some portion of tokens
    uint256 burnAmount = _rentFee * burnRate / 100;
    ERC20Burnable(fukcingToken).burnFrom(_user, burnAmount);

    // Get money
    ERC20(fukcingToken).transfer(_lordAddress, _rentFee - burnAmount);

    // Rent the NFT
    bytes memory payload = abi.encodeWithSignature("setUser(uint256,address,uint256)", _lordID, _user, _expires);
    (bool txSuccess, ) = fukcingLord.call(payload);
    require(txSuccess, "Transaction has fail to set rent from the Fukcing Lord contract!");
  }
}