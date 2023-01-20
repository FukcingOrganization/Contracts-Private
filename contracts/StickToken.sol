// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
  * @notice:
  * -> STICK token has dynamic minting mechanism. Every allocation part has its mint per second to mint in any time.
  *
  * -> maxSupply can change by DAO 10 days long proposal with %90 approval rate after 2 years from
  * and there is 1 month left to reach the current max supply
  *
  * -> Mint rate can chage with same hard approval after 1 year: backers, clans, community, staking
  *
  * -> 51% of the executors can pause/unpause the STICK token.
  */

/**
  * -> Vesting Mechanism                                                        //   Ether per sec         Wei per sec         Year
  * Backers     -> Round gets automatically         //                          // 0.224538876188384    224538876188384000      3 
  * Clans       -> Clan contract gets automatically                             // 0.224538876188384    224538876188384000      3 
  * Community   -> Executors pulls to the contract  //                          // 0.0748462920627947   74846292062794700       3 
  * Staking     -> Executors pulls to the contract  // New Contract (later)     // 0.0748462920627947   74846292062794700       3 
  * SDAO        -> Executors pulls to the contract                              // 0.0374231460313974   37423146031397400       3 
  * Dev         -> Executors pulls to a EOA         // 2 yr                     // 0.112269438094192    112269438094192000      1
  * Testnet     -> Individual claim with 66 Level   // 1 yr - 10% TGE           // 0.112269438094192    112269438094192000      1  
  * Team        -> Individual claim                 // 3 yr                     // 0.112269438094192    112269438094192000      1 
  *
  * Clans' claim can not exceed the total supply of DAO tokens !! 
  * Therefore, DAO members (most of them are clans) should approve new DAO token mints that are proposed by the Executors.
  */

/**
 * @author Bora
 */

contract StickToken is ERC20, ERC20Burnable, ERC20Snapshot, Pausable {

    enum Status{
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }

    struct Proposal {
        Status status;
        uint256 updateCode; // Update code helps to differentiate different variables with same data type. Starts from 1.
        bool isExecuted;    // If executed, the data and proposal no longer can be used.
        
        uint256 index;      // The index of target array. See arrays below.
        uint256 newUint;
        address newAddress;
        bytes32 newBytes32;
        bool newBool;
    }

    mapping(uint256 => Proposal) public proposals;          // Proposal ID => Proposal
    mapping(address => uint256) public allowancePerSecond;  // address => allowance per second in WEI
    mapping(address => uint256) public claimedAllowance;    // address => total claimed allowance

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

    /**
     * mintPerSecond's Indexes with corresponding meaning
     *  
     * Index 0: Backer's         -> 224538876188384000   wei  
     * Index 1: Clan's           -> 224538876188384000   wei   
     * Index 2: Community's      -> 74846292062794700    wei    
     * Index 3: Staking          -> 74846292062794700    wei
     * Index 4: DAO's            -> 37423146031397400    wei
     * Index 5: Development      -> 112269438094192000   wei
     */
    uint256[6] public mintPerSecond; // Mint per second in Wei for all allocation

    /** 
        If we want to change a function's proposal type, then we can simply change its type index

        Index : Associated Function
        0: Contract address update
        1: Functions Proposal Types update
        2: Mint per second
        3: Increase max supply
    */
    uint256[4] public functionsProposalTypes;
    
    /**
     * totalMints's Indexes with corresponding meaning
     *  
     * Index 0: Backer's         -> 224538876188384000   wei
     * Index 1: Clan's           -> 224538876188384000   wei
     * Index 2: Community's      -> 74846292062794700    wei
     * Index 3: Staking          -> 74846292062794700    wei
     * Index 4: DAO's            -> 37423146031397400    wei
     * Index 5: Development      -> 112269438094192000   wei
     * Index 6: Testnet          -> 112269438094192000   wei
     * Index 7: Team             -> 112269438094192000   wei
     */
    uint256[8] public totalMints; // Minted Amount for each allocation subject 

    uint256[6] public testnetMintPerSecond;
    bytes32[6] public testnetRoots;
    address[] teamAddress;                      // Test -> add team members total number like testnet
    uint256[] teamMintPerSecond;

    uint256 public deploymentTime;
    uint256 public oneYearLater;
    uint256 public twoYearsLater;
    uint256 public communityTGErelease;         // 12,307,196   Unix time    -> ~142 days
    uint256 public testnetTGErelease;           // 4,102,399    Unix time    -> ~47 days
    uint256 public maxSupply = 70857567 ether;        // ~70 million initial max supply
    uint256 public teamAndTestnetCap = 3542878 ether; // ~3.5 million for both team and testnet allocation
    
    constructor(
        address[] memory _teamAddress,          // TEST -> Add the size here as well
        uint256[] memory _teamMintPerSecond,
        bytes32[6] memory _testnetRoots,
        uint256[6] memory _testnetMintPerSecond
    ) 
        ERC20("StickToken", "STICK") 
    {
        deploymentTime = block.timestamp;   // Test -> Add the exact date here as comment for people to see
        oneYearLater = deploymentTime + 31556926;   // Add 1 year
        twoYearsLater = oneYearLater + 31556926;    // Add 1 more year
        teamAddress = _teamAddress;
        teamMintPerSecond = _teamMintPerSecond;
        testnetRoots = _testnetRoots;
        testnetMintPerSecond = _testnetMintPerSecond;
    }

    function snapshot() public {
        require(_msgSender() == contracts[5], "Only executor contract can call this function!");
        _snapshot();
    }

    function pause() public {
        require(_msgSender() == contracts[5], "Only executor contract can call this function!");
        _pause();
    }

    function unpause() public {
        require(_msgSender() == contracts[5], "Only executor contract can call this function!");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Vesting Mechanism - Dynamic Mint 

    function backerMint() public returns (uint256){
        require(_msgSender() == contracts[9], "Only the Round contract can call this function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");

        // Mint starts 7 days before the token deployment to reward backers and players for the initial round
        uint256 totalReward = (block.timestamp - (deploymentTime - 7 days)) * mintPerSecond[0]; // TEST -> make it 7 days
        uint256 currentReward = totalReward - totalMints[0];

        totalMints[0] += currentReward;

        _mint(contracts[9], currentReward);

        return currentReward;
    }

    function clanMint() public returns (uint256){
        require(_msgSender() == contracts[1], "Only the Clan contract can call this function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");

        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[1];
        uint256 currentReward = totalReward - totalMints[1];

        // DAO token supply should be equal or greater than the total clan reward 
        // to encourage DAO members to approve new mint proposals.
        require(ERC20(contracts[4]).totalSupply() >= totalReward, "Not enough DAO tokens! DAO should approve new token mints!");

        totalMints[1] += currentReward;

        _mint(contracts[1], currentReward);

        return currentReward;
    }

    function availableCommunityMint() public view returns (uint256) {
        // Calculate current total reward
        uint256 totalReward = (block.timestamp - (deploymentTime - communityTGErelease)) * mintPerSecond[2];

        // Return the current available reward by subtracting the already claimed reward
        return totalReward - totalMints[2];    
    }

    function communityMint(uint256 _amount) public returns (bool){
        require(_msgSender() == contracts[3], "Only the Community can call this function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - (deploymentTime - communityTGErelease)) * mintPerSecond[2];
        uint256 currentReward = totalReward - totalMints[2];

        require(currentReward >= _amount, "Not enough available reward!");

        totalMints[2] += _amount;

        _mint(contracts[3], _amount);

        return true;
    }

    function stakingMint() public returns (uint256){        
        require(_msgSender() == contracts[5], "Only the Executors can call this function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[3];
        uint256 currentReward = totalReward - totalMints[3];

        totalMints[3] += currentReward;

        _mint(contracts[10], currentReward);

        return currentReward;
    }

    function avaliableDaoMint() public view returns (uint256){                
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[4];

        return totalReward - totalMints[4];
    }

    function daoMint(uint256 _amount) public returns (bool){        
        require(_msgSender() == contracts[5], "Only the Executors can call this function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[4];
        uint256 currentReward = totalReward - totalMints[4];

        require(currentReward >= _amount, "Not enough available reward!");

        totalMints[4] += _amount;

        _mint(contracts[4], _amount);

        return true;
    }

    function testnetMint(bytes32[] calldata _merkleProof) public {
        require(block.timestamp <= oneYearLater - testnetTGErelease, "Testnet vesting period ended!");
        require(totalMints[6] <= teamAndTestnetCap, "All of testnet allocation has been minted!");

        
        uint256 totalReward = calculateTesterReward(_merkleProof);
        require(totalReward > 0, "Bruh, you don't have any allowance! Maybe next time ;)");

        uint256 currentReward = totalReward - claimedAllowance[_msgSender()];
        claimedAllowance[_msgSender()] += currentReward;
        totalMints[6] += currentReward;

        _mint(_msgSender(), currentReward);

        // Mint SDAO tokens as many as the testnet participation reward
        (bool txSuccess,) = contracts[4].call(abi.encodeWithSignature("mintTokens(address,uint256)", _msgSender(), currentReward));
        require(txSuccess, "Transaction failed to mint new SDAO tokens!");
    }

    function availableDevelopmentMint() public view returns (uint256){    
        require(block.timestamp <= oneYearLater, "Development vesting period ended!");    
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[5];
        return totalReward - totalMints[5];
    }

    function developmentMint(uint256 _amount) public returns (bool){        
        require(_msgSender() == contracts[5], "Only the Executors can call this function!");
        require(block.timestamp <= oneYearLater, "Development vesting period ended!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[5];
        uint256 currentReward = totalReward - totalMints[5];

        require(currentReward >= _amount, "Not enough available reward!");

        totalMints[5] += _amount;

        _mint(contracts[12], _amount);

        return true;
    }

    function availableTeamMint(uint256 _index) public view returns (uint256) {
        require(block.timestamp <= oneYearLater, "Team vesting period ended!");

        uint256 totalReward = (block.timestamp - deploymentTime) * teamMintPerSecond[_index];
        return totalReward - claimedAllowance[teamAddress[_index]];
    }

    function teamMint(uint256 _index, uint256 _amount) public {
        require(_msgSender() == teamAddress[_index], "You don't share the team allocation, check your wallet address! Dummy!");
        require(block.timestamp <= oneYearLater, "Team vesting period ended!");
        require(totalMints[7] <= teamAndTestnetCap, "The team members minted all of their allocation!");

        uint256 totalReward = (block.timestamp - deploymentTime) * teamMintPerSecond[_index];
        uint256 currentReward = totalReward - claimedAllowance[teamAddress[_index]];

        require(currentReward >= _amount, "Not enough available reward!");

        claimedAllowance[teamAddress[_index]] += _amount;
        totalMints[7] += _amount;

        _mint(teamAddress[_index], _amount);

        // Mint SDAO tokens as many as the team reward
        (bool txSuccess,) = contracts[4].call(abi.encodeWithSignature("mintTokens(address,uint256)", teamAddress[_index], _amount));
        require(txSuccess, "Transaction failed to mint new SDAO tokens!");
    }

    function calculateTesterReward(bytes32[] calldata _merkleProof) internal view returns (uint256) {
        uint256 totalReward;
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        // Search in all roots
        for (uint256 i = 0; i < testnetRoots.length; i++){

            // If the proof valid for this index, get the reward for this index
            if (MerkleProof.verify(_merkleProof, testnetRoots[i], leaf)){

                // Tester mint date starts ~36 days ago to have 10% TGE unlock which is 500k tokens.
                totalReward = (block.timestamp - (deploymentTime - testnetTGErelease)) * testnetMintPerSecond[i];
                break;
            }
        }

        return totalReward;
    }

    /**
     * Updates by DAO - Update Codes
     *
     * Contract Address Change -> Code: 1
     * Proposal Type Change -> Code: 2
     * Mint Per Second -> Code: 3
     * maxSupply -> Code: 4
     * 
     */

    function proposeContractAddressUpdate(uint256 _contractIndex, address _newAddress) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(_newAddress != address(0) || _newAddress != contracts[_contractIndex], 
            "New address can not be the null or same address!"
        );

        string memory proposalDescription = string(abi.encodePacked(
            "In StickToken contract, updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
            Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
        )); 
 
        // Create a new proposal - Call DAO contract (contracts[4])
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[0])
        );
        require(txSuccess, "Transaction failed to make new proposal!");
 
        // Save the ID to create proposal in here
        (uint256 propID) = abi.decode(returnData, (uint256));

        // Save data to the proposal
        proposals[propID].updateCode = 1;
        proposals[propID].index = _contractIndex;
        proposals[propID].newAddress = _newAddress;
    }

    function executeContractAddressUpdateProposal(uint256 _proposalID) public {
        Proposal storage proposal = proposals[_proposalID];

        require(proposal.updateCode == 1 && !proposal.isExecuted, "Wrong proposal ID");
        
        // Get the result from DAO
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
        );
        require(txSuccess, "Transaction failed to retrieve DAO result!");
        (uint256 statusNum) = abi.decode(returnData, (uint256));

        // Save it here
        proposal.status = Status(statusNum);

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
            "In Token contract, updating proposal types of index ", Strings.toHexString(_functionIndex), 
            " to ", Strings.toHexString(_newIndex), " from ", Strings.toHexString(functionsProposalTypes[_functionIndex]), "."
        ));

        // Create a new proposal - Call DAO contract (contracts[4])
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[1])
        );
        require(txSuccess, "Transaction failed to make new proposal!");

        // Save the ID
        (uint256 propID) = abi.decode(returnData, (uint256));

        // Get data to the proposal
        proposals[propID].updateCode = 2;
        proposals[propID].index = _functionIndex;
        proposals[propID].newUint = _newIndex;
    }
    
    function executeFunctionsProposalTypesUpdateProposal(uint256 _proposalID) public {
        Proposal storage proposal = proposals[_proposalID];

        require(proposal.updateCode == 2 && !proposal.isExecuted, "Wrong proposal ID");

        // If there is already a proposal, Get its result from DAO
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
        );
        require(txSuccess, "Transaction failed to retrieve DAO result!");
        (uint256 statusNum) = abi.decode(returnData, (uint256));

        // Save it here
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            functionsProposalTypes[proposal.index] = proposal.newUint;

        proposal.isExecuted = true;
    }

    function proposeMintPerSecondUpdate(uint256 _mintIndex, uint256 _newMintPerSecond) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(block.timestamp > oneYearLater, "You can't change tokenomics till end of the first year!");

        require(_newMintPerSecond != mintPerSecond[_mintIndex], "Mint rates are already the same moron, check your input!");

        if (_newMintPerSecond > mintPerSecond[_mintIndex]){
            uint256 changeRate = (_newMintPerSecond - mintPerSecond[_mintIndex]) * 100 / mintPerSecond[_mintIndex];
            require(changeRate <= 10, "New mint per second can only have 10% change!");
        }
        else {                
            uint256 changeRate = (mintPerSecond[_mintIndex] - _newMintPerSecond) * 100 / mintPerSecond[_mintIndex];
            require(changeRate <= 10, "New mint per second can only have 10% change!");
        }

        string memory proposalDescription = string(abi.encodePacked(
            "Updating mint per second of index ", Strings.toHexString(_mintIndex), " to ", 
            Strings.toHexString(_newMintPerSecond), " from ", Strings.toHexString(mintPerSecond[_mintIndex]), "."
        )); 

        // Create a new proposal - Call DAO contract (contracts[4])
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[2])
        );
        require(txSuccess, "Transaction failed to make new proposal!");

        // Save the ID to create proposal in here
        (uint256 propID) = abi.decode(returnData, (uint256));

        // Save data to the proposal
        proposals[propID].updateCode = 3;
        proposals[propID].index = _mintIndex;
        proposals[propID].newUint = _newMintPerSecond;
    }

    function executeMintPerSecondProposal(uint256 _proposalID) public {
        Proposal storage proposal = proposals[_proposalID];

        require(proposal.updateCode == 3 && !proposal.isExecuted, "Wrong proposal ID");

        // If the variable is the same (updateCode), then get its result from DAO
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
        );
        require(txSuccess, "Transaction failed to retrieve DAO result!");
        (uint256 statusNum) = abi.decode(returnData, (uint256));

        // Save it here
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if approved, apply the update the state
        if (proposal.status == Status.Approved)
            mintPerSecond[proposal.index] = proposal.newUint;

        proposal.isExecuted = true;
    }

    function proposeToIncreaseMaxSupply(uint256 _newMaxSupply) public {
        require(_msgSender() == contracts[5], "Only executors can call this function!");
        require(block.timestamp > twoYearsLater, "You can't increase the max supply till end of the second year!");
        require(_newMaxSupply > maxSupply, "New max supply can't be equal or lower than the current one");

        // Max supply can be increased by maxiumum of 10% at a time
        uint256 changeRate = (_newMaxSupply - maxSupply) * 100 / maxSupply;
        require(changeRate <= 10, "New mint per second can only have 10% change!");

        string memory proposalDescription = string(abi.encodePacked(
            "MAX SUPPLY CHANGE !! NEW SUPPLY: ", Strings.toHexString(_newMaxSupply), 
            ". The current supply is ", Strings.toHexString(maxSupply), "."
        )); 

        // Create a new proposal - Call DAO contract (contracts[4])
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, functionsProposalTypes[3])
        );
        require(txSuccess, "Transaction failed to make new proposal!");

        // Save the ID
        (uint256 propID) = abi.decode(returnData, (uint256));

        // Save data to the proposal
        proposals[propID].updateCode = 4;
        proposals[propID].newUint = _newMaxSupply;
    }

    function executeIncreaseMaxSupplyProposal(uint256 _proposalID) public {
        Proposal storage proposal = proposals[_proposalID];

        require(proposal.updateCode == 4 && !proposal.isExecuted, "Wrong proposal ID");

        // Get the result from DAO
        (bool txSuccess, bytes memory returnData) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", _proposalID)
        );
        require(txSuccess, "Transaction failed to retrieve DAO result!");
        (uint256 statusNum) = abi.decode(returnData, (uint256));

        // Save it here
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        require(uint256(proposal.status) > 1, "The proposal still going on or not even started!");

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            maxSupply = proposal.newUint;

        proposal.isExecuted = true;
    }
}


