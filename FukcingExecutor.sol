// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
  * -> Executers triggers function in other contracts with 1/3 approval rate
  * -> Fire and hire executors with FDAO approval with 80% approval rate
  * -> Set a maximum number for executors to give point to clans. Point reduction requires DAO approval with a high approval rate!!
  * -> Executers gets their salary
  * -> Update: DAO add, ExecutorChange proposal type, executer trigger rate
  */

/*
 * @author Bora
 */
 
/**
  * @notice:
  * -> Each token ID is represents the lords' ID that mint it. For instance, licence with id 5 is the licence of lord ID 5.
  * -> Executers proposes changes in mintCost to FDAO to approve.
  */