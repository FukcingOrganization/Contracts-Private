// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
  * @notice:
  * -> maxSupply can change by DAO 13 days long proposal with %90 approval rate after there is 1 month left until the max supply
  * -> Mint rate can chage with same hard approval after 1 year: backers, clans, community, staking
  * -> Make changable all the receivers except testnet and team. The address of them.
  */

/**
  * -> Vesting Mechanism                                                        //   Ether per sec         Wei per sec         Year
  * Backers     -> Seance gets automatically        // 7days (0.6%) TGE         // 0.224538876188384    224538876188384000      3 
  * Clans       -> Clan contract gets automatically                             // 0.224538876188384    224538876188384000      3 
  * Community   -> Executors pulls to the contract  // 13% TGE                  // 0.0748462920627947   74846292062794700       3 
  * Staking     -> Executors pulls to the contract  // New Contract (later)     // 0.0748462920627947   74846292062794700       3 
  * FDAO        -> Executors pulls to the contract                              // 0.0374231460313974   37423146031397400       3 
  * Dev         -> Executors pulls to a EOA         // 1 yr                     // 0.112269438094192    112269438094192000      1
  * Testnet     -> Individual claim with 66 Level   // 1 yr - 13% TGE           // 0.112269438094192    112269438094192000      1  
  * Team        -> Individual claim                 // 1 yr                     // 0.112269438094192    112269438094192000      1 
  *
  * Clans' claim can not exceed the total supply of DAO tokens !! 
  * Therefore, DAO members (most of them are clans) should approve new DAO token mints that are proposed by the Executors.
  */

/*
 * @author Bora
 */

contract FukcingToken is ERC20, ERC20Burnable, ERC20Snapshot, Pausable {

    enum Status{
        NotStarted, // Index: 0
        OnGoing,    // Index: 1
        Approved,   // Index: 2
        Denied      // Index: 3
    }

    struct Proposal {
        Status status;
        string description;
        uint256 newUint;
        address newAddress;
        bytes32 newBytes32;
        bool newBool;
    }

    mapping(uint256 => Proposal) public proposals;          // proposalID => Proposal
    mapping(address => uint256) public allowancePerSecond;  // address => allowance per second in WEI
    mapping(address => uint256) public claimedAllowance;    // address => total claimed allowance

    /**
    * contracts' Indexes with corresponding meaning
    *  
    * Index 0: Boss Contract                // Proposal ID Tracker (PID) : 0
    * Index 1: Clan Contract                // PID: 1
    * Index 2: ClanLicence Contract         // PID: 2
    * Index 3: Community Contract           // PID: 3
    * Index 4: DAO Contract                 // PID: 4
    * Index 5: Executor Contract            // PID: 5
    * Index 6: Items Contract               // PID: 6
    * Index 7: Lord Contract                // PID: 7
    * Index 8: Rent Contract                // PID: 8
    * Index 9: Seance Contract              // PID: 9
    * Index 10: Staking Contract            // PID: 10
    * Index 11: Token Contract              // PID: 11
    * Index 12: Developer Contract/address  // PID: 12
    */
    address[13] public contracts;  

    /// PID 13 is maxSupply change, see below!

    /**
    * mintPerSecond's Indexes with corresponding meaning
    *  
    * Index 0: Backer's         -> 224538876188384000   wei     // PID: 14
    * Index 1: Clan's           -> 224538876188384000   wei     // PID: 15
    * Index 2: Community's      -> 74846292062794700    wei     // PID: 16
    * Index 3: Staking          -> 74846292062794700    wei     // PID: 17
    * Index 4: DAO's            -> 37423146031397400    wei     // PID: 18
    * Index 5: Development      -> 112269438094192000   wei     // PID: 19
    */
    uint256[6] public mintPerSecond; // Mint per second in Wei for all allocation

    /**
    * proposalTypes's Indexes with corresponding meaning
    *  
    * Index 0: Less important proposals         // PID: 20
    * Index 1: Moderately important proposals   // PID: 21
    * Index 2: Highly important proposals       // PID: 22
    * Index 3: MAX SUPPLY CHANGE PROPOSAL       // PID: 23
    */
    uint256[4] public proposalTypes; // Minted Amount for each allocation subject 
    
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

    uint256[13] public testnetMintPerSecond;
    bytes32[13] public testnetRoots;
    address[] teamAddress;                      // Test -> add team members total number like testnet
    uint256[] teamMintPerSecond;

    uint256 public deploymentTime;
    uint256 public oneYearLater;
    uint256 public twoYearsLater;
    uint256 public communityTGErelease;         // 12,307,196   Unix time    -> ~142 days
    uint256 public testnetTGErelease;           // 4,102,399    Unix time    -> ~47 days
    uint256 public maxSupply = 70857567 ether;        // ~70 million initial max supply - PID: 13
    uint256 public teamAndTestnetCap = 3542878 ether; // ~3.5 million for both team and testnet allocation

    uint256[24] public proposalIdTracker;
    
    constructor(
        address[] memory _teamAddress,          // TEST -> Add the size here as well
        uint256[] memory _teamMintPerSecond,
        bytes32[13] memory _testnetRoots,
        uint256[13] memory _testnetMintPerSecond
    ) 
        ERC20("FukcingToken", "FUKC") 
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
        require(_msgSender() == contracts[9], "Only the Fukcing Seance contract can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");

        // Mint starts 7 days before the token deployment to reward backers and players for the initial seance
        uint256 totalReward = (block.timestamp - (deploymentTime - 7 days)) * mintPerSecond[0]; // TEST -> make it 7 days
        uint256 currentReward = totalReward - totalMints[0];

        totalMints[0] += currentReward;

        _mint(contracts[9], currentReward);

        return currentReward;
    }

    function clanMint() public returns (uint256){
        require(_msgSender() == contracts[1], "Only the Fukcing Clan contract can call this fukcing function!");
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

    function communityMint() public returns (uint256){
        require(_msgSender() == contracts[3], "Only the Fukcing Community can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        // Community mint date starts ~142 days ago to have 13% TGE which is 921k tokens.
        uint256 totalReward = (block.timestamp - (deploymentTime - communityTGErelease)) * mintPerSecond[2];
        uint256 currentReward = totalReward - totalMints[2];

        totalMints[2] += currentReward;

        _mint(contracts[3], currentReward);

        return currentReward;
    }

    function stakingMint() public returns (uint256){        
        require(_msgSender() == contracts[5], "Only the Fukcing Executors can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[3];
        uint256 currentReward = totalReward - totalMints[3];

        totalMints[3] += currentReward;

        _mint(contracts[10], currentReward);

        return currentReward;
    }

    function daoMint() public returns (uint256){        
        require(_msgSender() == contracts[5], "Only the Fukcing Executors can call this fukcing function!");
        require(totalSupply() <= maxSupply, "Max supply has been reached!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[4];
        uint256 currentReward = totalReward - totalMints[4];

        totalMints[4] += currentReward;

        _mint(contracts[4], currentReward);

        return currentReward;
    }

    function testnetMint(bytes32[] calldata _merkleProof) public {
        require(block.timestamp <= oneYearLater - testnetTGErelease, "Testnet vesting period ended!");
        require(totalMints[6] <= teamAndTestnetCap, "All of testnet allocation has been minted!");

        
        uint256 totalReward = calculateTestnetReward(_merkleProof);
        require(totalReward > 0, "Bruh, you don't have any allowance! Maybe next time ;)");

        uint256 currentReward = totalReward - claimedAllowance[_msgSender()];
        claimedAllowance[_msgSender()] += currentReward;
        totalMints[6] += currentReward;

        _mint(_msgSender(), currentReward);
    }

    function developmentMint() public returns (uint256){        
        require(_msgSender() == contracts[5], "Only the Fukcing Executors can call this fukcing function!");
        require(block.timestamp <= oneYearLater, "Development vesting period ended!");
        
        uint256 totalReward = (block.timestamp - deploymentTime) * mintPerSecond[5];
        uint256 currentReward = totalReward - totalMints[5];

        totalMints[5] += currentReward;

        _mint(contracts[12], currentReward);

        return currentReward;
    }

    function teamMint(uint256 _index) public {
        require(_msgSender() == teamAddress[_index], "You don't share the team allocation, check your wallet address! Dummy!");
        require(block.timestamp <= oneYearLater, "Team vesting period ended!");
        require(totalMints[7] <= teamAndTestnetCap, "The team members minted all of their allocation!");

        uint256 totalReward = (block.timestamp - deploymentTime) * teamMintPerSecond[_index];
        uint256 currentReward = totalReward - claimedAllowance[teamAddress[_index]];

        claimedAllowance[teamAddress[_index]] += currentReward;
        totalMints[7] += currentReward;

        _mint(teamAddress[_index], currentReward);
    }

    function calculateTestnetReward(bytes32[] calldata _merkleProof) internal view returns (uint256) {
        uint256 totalReward;
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        
        // Search in all roots
        for (uint256 i = 0; i < testnetRoots.length; i++){

            // If the proof valid for this index, get the reward for this index
            if (MerkleProof.verify(_merkleProof, testnetRoots[i], leaf)){

                // Community mint date starts ~142 days ago to have 13% TGE which is 921k tokens.
                totalReward = (block.timestamp - (deploymentTime - testnetTGErelease)) * testnetMintPerSecond[i];
                break;
            }
        }

        return totalReward;
    }

    // Updates by DAO - contracts(13), mintPerSecond(6), maxSupply, proposalTypes

    /**
     * @dev isNewProposal is optional be good to have to be sure the executors are making a new proposal.
     * Since applying the proposal status to the state requires to run the same function.
     * PID starts from 0 to 12. Matches with contractIndex.
     */

    function updateContractAddress(
        uint256 _contractIndex, 
        address _newAddress, 
        bool _isNewProposal
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

        // if PID[_contractIndex] is 0, make a new proposal
        if (proposalIdTracker[_contractIndex] == 0 && _isNewProposal) {
            require(_newAddress != address(0), "New address can not be the null address!");

            string memory proposalDescription = string(abi.encodePacked(
                "Updating contract address of index ", Strings.toHexString(_contractIndex), " to ", 
                Strings.toHexString(_newAddress), " from ", Strings.toHexString(contracts[_contractIndex]), "."
            )); 

            // Create a new proposal - Call DAO contract (contracts[4])
            (bool txSuccess0, bytes memory returnData0) = contracts[4].call(
                abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
            );
            require(txSuccess0, "Transaction failed to make new proposal!");

            // Save the ID to PID[_contractIndex]
            (proposalIdTracker[_contractIndex]) = abi.decode(returnData0, (uint256));

            // Get new state update by proposal ID we get from newProposal
            proposals[proposalIdTracker[_contractIndex]].newAddress = _newAddress;

            return; // Finish the function
        }

        // If there is already a proposal, Get its result from DAO
        (bool txSuccess1, bytes memory returnData1) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", proposalIdTracker[_contractIndex])
        );
        require(txSuccess1, "Transaction failed to make new proposal!");
        (uint256 statusNum) = abi.decode(returnData1, (uint256));

        // Save it here
        Proposal storage proposal = proposals[proposalIdTracker[_contractIndex]];
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
            " Wait for the DAO decision on the proposal! The proposal ID = ", Strings.toString(proposalIdTracker[_contractIndex]), "."
        )); 
        require(uint256(proposal.status) > 1, errorText);

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            contracts[_contractIndex] = proposal.newAddress;

        proposalIdTracker[_contractIndex] = 0;   // reset proposal tracker
    }

    // PID's starts from 14 to 19. So, add 14 to the _mintIndex to get corresponding PID
    function updateMintPerSecond(
        uint256 _mintIndex, 
        uint256 _newMintPerSecond, 
        bool _isNewProposal
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        require(block.timestamp > oneYearLater, "You can't change tokenomics till end of the first year!");

        // if PID[_mintIndex + 14] is 0, make a new proposal
        if (proposalIdTracker[_mintIndex + 14] == 0 && _isNewProposal) {
            require(_newMintPerSecond != mintPerSecond[_mintIndex], "Mint rates are already the same moron, check your input!");

            if (_newMintPerSecond > mintPerSecond[_mintIndex]){
                uint256 changeRate = (_newMintPerSecond - mintPerSecond[_mintIndex]) * 100 / mintPerSecond[_mintIndex];
                require(changeRate <= 13, "New mint per second can only have 13% change!");
            }
            else {                
                uint256 changeRate = (mintPerSecond[_mintIndex] - _newMintPerSecond) * 100 / mintPerSecond[_mintIndex];
                require(changeRate <= 13, "New mint per second can only have 13% change!");
            }

            string memory proposalDescription = string(abi.encodePacked(
                "Updating mint per second of index ", Strings.toHexString(_mintIndex), " to ", 
                Strings.toHexString(_newMintPerSecond), " from ", Strings.toHexString(mintPerSecond[_mintIndex]), "."
            )); 

            // Create a new proposal - Call DAO contract (contracts[4])
            (bool txSuccess0, bytes memory returnData0) = contracts[4].call(
                abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
            );
            require(txSuccess0, "Transaction failed to make new proposal!");

            // Save the ID to PID[_mintIndex + 14]
            (proposalIdTracker[_mintIndex + 14]) = abi.decode(returnData0, (uint256));

            // Get new state update by proposal ID we get from newProposal
            proposals[proposalIdTracker[_mintIndex + 14]].newUint = _newMintPerSecond;

            return; // Finish the function
        }

        // If there is already a proposal, Get its result from DAO
        (bool txSuccess1, bytes memory returnData1) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", proposalIdTracker[_mintIndex + 14])
        );
        require(txSuccess1, "Transaction failed to make new proposal!");
        (uint256 statusNum) = abi.decode(returnData1, (uint256));

        // Save it here
        Proposal storage proposal = proposals[proposalIdTracker[_mintIndex + 14]];
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
            " Wait for the DAO decision on the proposal! The proposal ID = ", 
            Strings.toString(proposalIdTracker[_mintIndex + 14]), "."
        )); 
        require(uint256(proposal.status) > 1, errorText);

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            mintPerSecond[_mintIndex] = proposal.newUint;

        proposalIdTracker[_mintIndex + 14] = 0;   // reset proposal tracker
    }

    // PID : 13
    function increaseMaxSupply(
        uint256 _newMaxSupply, 
        bool _isNewProposal
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");
        require(block.timestamp > twoYearsLater, "You can't increase the max supply till end of the second year!");
        require(_newMaxSupply > maxSupply, "New max supply can't be equal or lower than the current one");

        // if PID[13] is 0, make a new proposal
        if (proposalIdTracker[13] == 0 && _isNewProposal) {

            // Max supply can be increased by maxiumum of 13% at a time
            uint256 changeRate = (_newMaxSupply - maxSupply) * 100 / maxSupply;
            require(changeRate <= 13, "New mint per second can only have 13% change!");

            string memory proposalDescription = string(abi.encodePacked(
                "MAX SUPPLY CHANGE !! NEW SUPPLY: ", Strings.toHexString(_newMaxSupply), 
                ". The current supply is ", Strings.toHexString(maxSupply), "."
            )); 

            // Create a new proposal - Call DAO contract (contracts[4])
            (bool txSuccess0, bytes memory returnData0) = contracts[4].call(
                abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[3])
            );
            require(txSuccess0, "Transaction failed to make new proposal!");

            // Save the ID to PID[13]
            (proposalIdTracker[13]) = abi.decode(returnData0, (uint256));

            // Get new state update by proposal ID we get from newProposal
            proposals[proposalIdTracker[13]].newUint = _newMaxSupply;

            return; // Finish the function
        }

        // If there is already a proposal, Get its result from DAO
        (bool txSuccess1, bytes memory returnData1) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", proposalIdTracker[13])
        );
        require(txSuccess1, "Transaction failed to make new proposal!");
        (uint256 statusNum) = abi.decode(returnData1, (uint256));

        // Save it here
        Proposal storage proposal = proposals[proposalIdTracker[13]];
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
            " Wait for the DAO decision on the proposal! The proposal ID = ", 
            Strings.toString(proposalIdTracker[13]), "."
        )); 
        require(uint256(proposal.status) > 1, errorText);

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            maxSupply = proposal.newUint;

        proposalIdTracker[13] = 0;   // reset proposal tracker
    }

    // PID's starts from 20 to 23. So, add 20 to the _proposalIndex to get corresponding PID
    function updateProposalTypes(
        uint256 _proposalIndex, 
        uint256 _newType, 
        bool _isNewProposal
    ) 
    public {
        require(_msgSender() == contracts[5], "Only executors can call this fukcing function!");

        // if PID[_proposalIndex + 20] is 0, make a new proposal
        if (proposalIdTracker[_proposalIndex + 20] == 0 && _isNewProposal) {
            require(_newType != proposalTypes[_proposalIndex], "Proposal Types are already the same moron, check your input!");

            string memory proposalDescription = string(abi.encodePacked(
                "Updating proposal types of index ", Strings.toHexString(_proposalIndex), " to ", 
                Strings.toHexString(_newType), " from ", Strings.toHexString(proposalTypes[_proposalIndex]), "."
            )); 

            // Create a new proposal - Call DAO contract (contracts[4])
            (bool txSuccess0, bytes memory returnData0) = contracts[4].call(
                abi.encodeWithSignature("newProposal(string,uint256)", proposalDescription, proposalTypes[2])
            );
            require(txSuccess0, "Transaction failed to make new proposal!");

            // Save the ID to PID[_proposalIndex + 20]
            (proposalIdTracker[_proposalIndex + 20]) = abi.decode(returnData0, (uint256));

            // Get new state update by proposal ID we get from newProposal
            proposals[proposalIdTracker[_proposalIndex + 20]].newUint = _newType;

            return; // Finish the function
        }

        // If there is already a proposal, Get its result from DAO
        (bool txSuccess1, bytes memory returnData1) = contracts[4].call(
            abi.encodeWithSignature("proposalResult(uint256)", proposalIdTracker[_proposalIndex + 20])
        );
        require(txSuccess1, "Transaction failed to make new proposal!");
        (uint256 statusNum) = abi.decode(returnData1, (uint256));

        // Save it here
        Proposal storage proposal = proposals[proposalIdTracker[_proposalIndex + 20]];
        proposal.status = Status(statusNum);

        // Wait for the current one to finalize
        string memory errorText = string(abi.encodePacked("The previous proposal is still going on bro.", 
            " Wait for the DAO decision on the proposal! The proposal ID = ", 
            Strings.toString(proposalIdTracker[_proposalIndex + 20]), "."
        )); 
        require(uint256(proposal.status) > 1, errorText);

        // if the current one is approved, apply the update the state
        if (proposal.status == Status.Approved)
            proposalTypes[_proposalIndex] = proposal.newUint;

        proposalIdTracker[_proposalIndex + 20] = 0;   // reset proposal tracker
    }
}


