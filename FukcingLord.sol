// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
  * -> Based on ERC-721
  * -> Has clans and clanCounter
  * -> Mint clanLicence (max 3 licence can exist in the same time)
  * -> Lord Treasury balance
  * -> Rebellion Mechanism
  * -> BaseTax, taxChangeRate, victoryCounter
  * -> Make it rentable
  * -> Update: DAO and Executer add, UpdatePropType, baseTax, taxchangeRate,
  */

/*
 * @author Bora
 */

/**
  * @notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */