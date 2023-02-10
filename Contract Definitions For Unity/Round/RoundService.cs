using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using Contracts.Contracts.Round.ContractDefinition;

namespace Contracts.Contracts.Round
{
    public partial class RoundService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, RoundDeployment roundDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<RoundDeployment>().SendRequestAndWaitForReceiptAsync(roundDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, RoundDeployment roundDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<RoundDeployment>().SendRequestAsync(roundDeployment);
        }

        public static async Task<RoundService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, RoundDeployment roundDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, roundDeployment, cancellationTokenSource);
            return new RoundService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public RoundService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }

        public Task<string> DEBUG_setContractRequestAsync(DEBUG_setContractFunction dEBUG_setContractFunction)
        {
             return ContractHandler.SendRequestAsync(dEBUG_setContractFunction);
        }

        public Task<TransactionReceipt> DEBUG_setContractRequestAndWaitForReceiptAsync(DEBUG_setContractFunction dEBUG_setContractFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_setContractFunction, cancellationToken);
        }

        public Task<string> DEBUG_setContractRequestAsync(string contractAddress, BigInteger index)
        {
            var dEBUG_setContractFunction = new DEBUG_setContractFunction();
                dEBUG_setContractFunction.ContractAddress = contractAddress;
                dEBUG_setContractFunction.Index = index;
            
             return ContractHandler.SendRequestAsync(dEBUG_setContractFunction);
        }

        public Task<TransactionReceipt> DEBUG_setContractRequestAndWaitForReceiptAsync(string contractAddress, BigInteger index, CancellationTokenSource cancellationToken = null)
        {
            var dEBUG_setContractFunction = new DEBUG_setContractFunction();
                dEBUG_setContractFunction.ContractAddress = contractAddress;
                dEBUG_setContractFunction.Index = index;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_setContractFunction, cancellationToken);
        }

        public Task<string> DEBUG_setContractsRequestAsync(DEBUG_setContractsFunction dEBUG_setContractsFunction)
        {
             return ContractHandler.SendRequestAsync(dEBUG_setContractsFunction);
        }

        public Task<TransactionReceipt> DEBUG_setContractsRequestAndWaitForReceiptAsync(DEBUG_setContractsFunction dEBUG_setContractsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_setContractsFunction, cancellationToken);
        }

        public Task<string> DEBUG_setContractsRequestAsync(List<string> contracts)
        {
            var dEBUG_setContractsFunction = new DEBUG_setContractsFunction();
                dEBUG_setContractsFunction.Contracts = contracts;
            
             return ContractHandler.SendRequestAsync(dEBUG_setContractsFunction);
        }

        public Task<TransactionReceipt> DEBUG_setContractsRequestAndWaitForReceiptAsync(List<string> contracts, CancellationTokenSource cancellationToken = null)
        {
            var dEBUG_setContractsFunction = new DEBUG_setContractsFunction();
                dEBUG_setContractsFunction.Contracts = contracts;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_setContractsFunction, cancellationToken);
        }

        public Task<string> ClaimBackerRewardRequestAsync(ClaimBackerRewardFunction claimBackerRewardFunction)
        {
             return ContractHandler.SendRequestAsync(claimBackerRewardFunction);
        }

        public Task<TransactionReceipt> ClaimBackerRewardRequestAndWaitForReceiptAsync(ClaimBackerRewardFunction claimBackerRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimBackerRewardFunction, cancellationToken);
        }

        public Task<string> ClaimBackerRewardRequestAsync(BigInteger roundNumber)
        {
            var claimBackerRewardFunction = new ClaimBackerRewardFunction();
                claimBackerRewardFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAsync(claimBackerRewardFunction);
        }

        public Task<TransactionReceipt> ClaimBackerRewardRequestAndWaitForReceiptAsync(BigInteger roundNumber, CancellationTokenSource cancellationToken = null)
        {
            var claimBackerRewardFunction = new ClaimBackerRewardFunction();
                claimBackerRewardFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimBackerRewardFunction, cancellationToken);
        }

        public Task<string> ClaimPlayerRewardRequestAsync(ClaimPlayerRewardFunction claimPlayerRewardFunction)
        {
             return ContractHandler.SendRequestAsync(claimPlayerRewardFunction);
        }

        public Task<TransactionReceipt> ClaimPlayerRewardRequestAndWaitForReceiptAsync(ClaimPlayerRewardFunction claimPlayerRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimPlayerRewardFunction, cancellationToken);
        }

        public Task<string> ClaimPlayerRewardRequestAsync(List<byte[]> merkleProof, BigInteger roundNumber)
        {
            var claimPlayerRewardFunction = new ClaimPlayerRewardFunction();
                claimPlayerRewardFunction.MerkleProof = merkleProof;
                claimPlayerRewardFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAsync(claimPlayerRewardFunction);
        }

        public Task<TransactionReceipt> ClaimPlayerRewardRequestAndWaitForReceiptAsync(List<byte[]> merkleProof, BigInteger roundNumber, CancellationTokenSource cancellationToken = null)
        {
            var claimPlayerRewardFunction = new ClaimPlayerRewardFunction();
                claimPlayerRewardFunction.MerkleProof = merkleProof;
                claimPlayerRewardFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimPlayerRewardFunction, cancellationToken);
        }

        public Task<string> ContractsQueryAsync(ContractsFunction contractsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ContractsFunction, string>(contractsFunction, blockParameter);
        }

        
        public Task<string> ContractsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var contractsFunction = new ContractsFunction();
                contractsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<ContractsFunction, string>(contractsFunction, blockParameter);
        }

        public Task<string> DefundBossRequestAsync(DefundBossFunction defundBossFunction)
        {
             return ContractHandler.SendRequestAsync(defundBossFunction);
        }

        public Task<TransactionReceipt> DefundBossRequestAndWaitForReceiptAsync(DefundBossFunction defundBossFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(defundBossFunction, cancellationToken);
        }

        public Task<string> DefundBossRequestAsync(BigInteger levelNumber, BigInteger bossID, BigInteger withdrawAmount)
        {
            var defundBossFunction = new DefundBossFunction();
                defundBossFunction.LevelNumber = levelNumber;
                defundBossFunction.BossID = bossID;
                defundBossFunction.WithdrawAmount = withdrawAmount;
            
             return ContractHandler.SendRequestAsync(defundBossFunction);
        }

        public Task<TransactionReceipt> DefundBossRequestAndWaitForReceiptAsync(BigInteger levelNumber, BigInteger bossID, BigInteger withdrawAmount, CancellationTokenSource cancellationToken = null)
        {
            var defundBossFunction = new DefundBossFunction();
                defundBossFunction.LevelNumber = levelNumber;
                defundBossFunction.BossID = bossID;
                defundBossFunction.WithdrawAmount = withdrawAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(defundBossFunction, cancellationToken);
        }

        public Task<string> ExecuteContractAddressUpdateProposalRequestAsync(ExecuteContractAddressUpdateProposalFunction executeContractAddressUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeContractAddressUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteContractAddressUpdateProposalRequestAndWaitForReceiptAsync(ExecuteContractAddressUpdateProposalFunction executeContractAddressUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeContractAddressUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteContractAddressUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeContractAddressUpdateProposalFunction = new ExecuteContractAddressUpdateProposalFunction();
                executeContractAddressUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeContractAddressUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteContractAddressUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeContractAddressUpdateProposalFunction = new ExecuteContractAddressUpdateProposalFunction();
                executeContractAddressUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeContractAddressUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteFunctionsProposalTypesUpdateProposalRequestAsync(ExecuteFunctionsProposalTypesUpdateProposalFunction executeFunctionsProposalTypesUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeFunctionsProposalTypesUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteFunctionsProposalTypesUpdateProposalRequestAndWaitForReceiptAsync(ExecuteFunctionsProposalTypesUpdateProposalFunction executeFunctionsProposalTypesUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeFunctionsProposalTypesUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteFunctionsProposalTypesUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeFunctionsProposalTypesUpdateProposalFunction = new ExecuteFunctionsProposalTypesUpdateProposalFunction();
                executeFunctionsProposalTypesUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeFunctionsProposalTypesUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteFunctionsProposalTypesUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeFunctionsProposalTypesUpdateProposalFunction = new ExecuteFunctionsProposalTypesUpdateProposalFunction();
                executeFunctionsProposalTypesUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeFunctionsProposalTypesUpdateProposalFunction, cancellationToken);
        }

        public Task<string> FundBossRequestAsync(FundBossFunction fundBossFunction)
        {
             return ContractHandler.SendRequestAsync(fundBossFunction);
        }

        public Task<TransactionReceipt> FundBossRequestAndWaitForReceiptAsync(FundBossFunction fundBossFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundBossFunction, cancellationToken);
        }

        public Task<string> FundBossRequestAsync(BigInteger levelNumber, BigInteger bossID, BigInteger fundAmount)
        {
            var fundBossFunction = new FundBossFunction();
                fundBossFunction.LevelNumber = levelNumber;
                fundBossFunction.BossID = bossID;
                fundBossFunction.FundAmount = fundAmount;
            
             return ContractHandler.SendRequestAsync(fundBossFunction);
        }

        public Task<TransactionReceipt> FundBossRequestAndWaitForReceiptAsync(BigInteger levelNumber, BigInteger bossID, BigInteger fundAmount, CancellationTokenSource cancellationToken = null)
        {
            var fundBossFunction = new FundBossFunction();
                fundBossFunction.LevelNumber = levelNumber;
                fundBossFunction.BossID = bossID;
                fundBossFunction.FundAmount = fundAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundBossFunction, cancellationToken);
        }

        public Task<string> GenesisCallRequestAsync(GenesisCallFunction genesisCallFunction)
        {
             return ContractHandler.SendRequestAsync(genesisCallFunction);
        }

        public Task<string> GenesisCallRequestAsync()
        {
             return ContractHandler.SendRequestAsync<GenesisCallFunction>();
        }

        public Task<TransactionReceipt> GenesisCallRequestAndWaitForReceiptAsync(GenesisCallFunction genesisCallFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(genesisCallFunction, cancellationToken);
        }

        public Task<TransactionReceipt> GenesisCallRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<GenesisCallFunction>(null, cancellationToken);
        }

        public Task<List<BigInteger>> GetBackerRewardsQueryAsync(GetBackerRewardsFunction getBackerRewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetBackerRewardsFunction, List<BigInteger>>(getBackerRewardsFunction, blockParameter);
        }

        
        public Task<List<BigInteger>> GetBackerRewardsQueryAsync(BigInteger roundNumber, BlockParameter blockParameter = null)
        {
            var getBackerRewardsFunction = new GetBackerRewardsFunction();
                getBackerRewardsFunction.RoundNumber = roundNumber;
            
            return ContractHandler.QueryAsync<GetBackerRewardsFunction, List<BigInteger>>(getBackerRewardsFunction, blockParameter);
        }

        public Task<string> GetCurrentRoundNumberRequestAsync(GetCurrentRoundNumberFunction getCurrentRoundNumberFunction)
        {
             return ContractHandler.SendRequestAsync(getCurrentRoundNumberFunction);
        }

        public Task<string> GetCurrentRoundNumberRequestAsync()
        {
             return ContractHandler.SendRequestAsync<GetCurrentRoundNumberFunction>();
        }

        public Task<TransactionReceipt> GetCurrentRoundNumberRequestAndWaitForReceiptAsync(GetCurrentRoundNumberFunction getCurrentRoundNumberFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(getCurrentRoundNumberFunction, cancellationToken);
        }

        public Task<TransactionReceipt> GetCurrentRoundNumberRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<GetCurrentRoundNumberFunction>(null, cancellationToken);
        }

        public Task<List<BigInteger>> GetPlayerRewardsQueryAsync(GetPlayerRewardsFunction getPlayerRewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetPlayerRewardsFunction, List<BigInteger>>(getPlayerRewardsFunction, blockParameter);
        }

        
        public Task<List<BigInteger>> GetPlayerRewardsQueryAsync(List<byte[]> merkleProof, BigInteger roundNumber, BlockParameter blockParameter = null)
        {
            var getPlayerRewardsFunction = new GetPlayerRewardsFunction();
                getPlayerRewardsFunction.MerkleProof = merkleProof;
                getPlayerRewardsFunction.RoundNumber = roundNumber;
            
            return ContractHandler.QueryAsync<GetPlayerRewardsFunction, List<BigInteger>>(getPlayerRewardsFunction, blockParameter);
        }

        public Task<bool> IsCandidateQueryAsync(IsCandidateFunction isCandidateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsCandidateFunction, bool>(isCandidateFunction, blockParameter);
        }

        
        public Task<bool> IsCandidateQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BigInteger candidateID, BlockParameter blockParameter = null)
        {
            var isCandidateFunction = new IsCandidateFunction();
                isCandidateFunction.RoundNumber = roundNumber;
                isCandidateFunction.LevelNumber = levelNumber;
                isCandidateFunction.CandidateID = candidateID;
            
            return ContractHandler.QueryAsync<IsCandidateFunction, bool>(isCandidateFunction, blockParameter);
        }

        public Task<BigInteger> LevelRewardWeightsQueryAsync(LevelRewardWeightsFunction levelRewardWeightsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<LevelRewardWeightsFunction, BigInteger>(levelRewardWeightsFunction, blockParameter);
        }

        
        public Task<BigInteger> LevelRewardWeightsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var levelRewardWeightsFunction = new LevelRewardWeightsFunction();
                levelRewardWeightsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<LevelRewardWeightsFunction, BigInteger>(levelRewardWeightsFunction, blockParameter);
        }

        public Task<BigInteger> ProposalTypeIndexQueryAsync(ProposalTypeIndexFunction proposalTypeIndexFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProposalTypeIndexFunction, BigInteger>(proposalTypeIndexFunction, blockParameter);
        }

        
        public Task<BigInteger> ProposalTypeIndexQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProposalTypeIndexFunction, BigInteger>(null, blockParameter);
        }

        public Task<ProposalsOutputDTO> ProposalsQueryAsync(ProposalsFunction proposalsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalsFunction, ProposalsOutputDTO>(proposalsFunction, blockParameter);
        }

        public Task<ProposalsOutputDTO> ProposalsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var proposalsFunction = new ProposalsFunction();
                proposalsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalsFunction, ProposalsOutputDTO>(proposalsFunction, blockParameter);
        }

        public Task<string> ProposeContractAddressUpdateRequestAsync(ProposeContractAddressUpdateFunction proposeContractAddressUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeContractAddressUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeContractAddressUpdateRequestAndWaitForReceiptAsync(ProposeContractAddressUpdateFunction proposeContractAddressUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeContractAddressUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeContractAddressUpdateRequestAsync(BigInteger contractIndex, string newAddress)
        {
            var proposeContractAddressUpdateFunction = new ProposeContractAddressUpdateFunction();
                proposeContractAddressUpdateFunction.ContractIndex = contractIndex;
                proposeContractAddressUpdateFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAsync(proposeContractAddressUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeContractAddressUpdateRequestAndWaitForReceiptAsync(BigInteger contractIndex, string newAddress, CancellationTokenSource cancellationToken = null)
        {
            var proposeContractAddressUpdateFunction = new ProposeContractAddressUpdateFunction();
                proposeContractAddressUpdateFunction.ContractIndex = contractIndex;
                proposeContractAddressUpdateFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeContractAddressUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(BigInteger newTypeIndex)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.NewTypeIndex = newTypeIndex;
            
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(BigInteger newTypeIndex, CancellationTokenSource cancellationToken = null)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.NewTypeIndex = newTypeIndex;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<byte[]> ReturnMerkleRootQueryAsync(ReturnMerkleRootFunction returnMerkleRootFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReturnMerkleRootFunction, byte[]>(returnMerkleRootFunction, blockParameter);
        }

        
        public Task<byte[]> ReturnMerkleRootQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BlockParameter blockParameter = null)
        {
            var returnMerkleRootFunction = new ReturnMerkleRootFunction();
                returnMerkleRootFunction.RoundNumber = roundNumber;
                returnMerkleRootFunction.LevelNumber = levelNumber;
            
            return ContractHandler.QueryAsync<ReturnMerkleRootFunction, byte[]>(returnMerkleRootFunction, blockParameter);
        }

        public Task<BigInteger> RoundCounterQueryAsync(RoundCounterFunction roundCounterFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundCounterFunction, BigInteger>(roundCounterFunction, blockParameter);
        }

        
        public Task<BigInteger> RoundCounterQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundCounterFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> RoundLengthQueryAsync(RoundLengthFunction roundLengthFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundLengthFunction, BigInteger>(roundLengthFunction, blockParameter);
        }

        
        public Task<BigInteger> RoundLengthQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundLengthFunction, BigInteger>(null, blockParameter);
        }

        public Task<RoundsOutputDTO> RoundsQueryAsync(RoundsFunction roundsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<RoundsFunction, RoundsOutputDTO>(roundsFunction, blockParameter);
        }

        public Task<RoundsOutputDTO> RoundsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var roundsFunction = new RoundsFunction();
                roundsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<RoundsFunction, RoundsOutputDTO>(roundsFunction, blockParameter);
        }

        public Task<string> SetPlayerMerkleRootAndNumberRequestAsync(SetPlayerMerkleRootAndNumberFunction setPlayerMerkleRootAndNumberFunction)
        {
             return ContractHandler.SendRequestAsync(setPlayerMerkleRootAndNumberFunction);
        }

        public Task<TransactionReceipt> SetPlayerMerkleRootAndNumberRequestAndWaitForReceiptAsync(SetPlayerMerkleRootAndNumberFunction setPlayerMerkleRootAndNumberFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerMerkleRootAndNumberFunction, cancellationToken);
        }

        public Task<string> SetPlayerMerkleRootAndNumberRequestAsync(BigInteger round, BigInteger level, byte[] root, BigInteger numberOfPlayers)
        {
            var setPlayerMerkleRootAndNumberFunction = new SetPlayerMerkleRootAndNumberFunction();
                setPlayerMerkleRootAndNumberFunction.Round = round;
                setPlayerMerkleRootAndNumberFunction.Level = level;
                setPlayerMerkleRootAndNumberFunction.Root = root;
                setPlayerMerkleRootAndNumberFunction.NumberOfPlayers = numberOfPlayers;
            
             return ContractHandler.SendRequestAsync(setPlayerMerkleRootAndNumberFunction);
        }

        public Task<TransactionReceipt> SetPlayerMerkleRootAndNumberRequestAndWaitForReceiptAsync(BigInteger round, BigInteger level, byte[] root, BigInteger numberOfPlayers, CancellationTokenSource cancellationToken = null)
        {
            var setPlayerMerkleRootAndNumberFunction = new SetPlayerMerkleRootAndNumberFunction();
                setPlayerMerkleRootAndNumberFunction.Round = round;
                setPlayerMerkleRootAndNumberFunction.Level = level;
                setPlayerMerkleRootAndNumberFunction.Root = root;
                setPlayerMerkleRootAndNumberFunction.NumberOfPlayers = numberOfPlayers;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setPlayerMerkleRootAndNumberFunction, cancellationToken);
        }

        public Task<BigInteger> TotalRewardWeightQueryAsync(TotalRewardWeightFunction totalRewardWeightFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalRewardWeightFunction, BigInteger>(totalRewardWeightFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalRewardWeightQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalRewardWeightFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> UpdateLevelRewardRatesRequestAsync(UpdateLevelRewardRatesFunction updateLevelRewardRatesFunction)
        {
             return ContractHandler.SendRequestAsync(updateLevelRewardRatesFunction);
        }

        public Task<TransactionReceipt> UpdateLevelRewardRatesRequestAndWaitForReceiptAsync(UpdateLevelRewardRatesFunction updateLevelRewardRatesFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateLevelRewardRatesFunction, cancellationToken);
        }

        public Task<string> UpdateLevelRewardRatesRequestAsync(List<BigInteger> newLevelWeights, BigInteger newTotalWeight)
        {
            var updateLevelRewardRatesFunction = new UpdateLevelRewardRatesFunction();
                updateLevelRewardRatesFunction.NewLevelWeights = newLevelWeights;
                updateLevelRewardRatesFunction.NewTotalWeight = newTotalWeight;
            
             return ContractHandler.SendRequestAsync(updateLevelRewardRatesFunction);
        }

        public Task<TransactionReceipt> UpdateLevelRewardRatesRequestAndWaitForReceiptAsync(List<BigInteger> newLevelWeights, BigInteger newTotalWeight, CancellationTokenSource cancellationToken = null)
        {
            var updateLevelRewardRatesFunction = new UpdateLevelRewardRatesFunction();
                updateLevelRewardRatesFunction.NewLevelWeights = newLevelWeights;
                updateLevelRewardRatesFunction.NewTotalWeight = newTotalWeight;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateLevelRewardRatesFunction, cancellationToken);
        }

        public Task<BigInteger> ViewBackerFundsQueryAsync(ViewBackerFundsFunction viewBackerFundsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewBackerFundsFunction, BigInteger>(viewBackerFundsFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewBackerFundsQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BigInteger candidateID, string backer, BlockParameter blockParameter = null)
        {
            var viewBackerFundsFunction = new ViewBackerFundsFunction();
                viewBackerFundsFunction.RoundNumber = roundNumber;
                viewBackerFundsFunction.LevelNumber = levelNumber;
                viewBackerFundsFunction.CandidateID = candidateID;
                viewBackerFundsFunction.Backer = backer;
            
            return ContractHandler.QueryAsync<ViewBackerFundsFunction, BigInteger>(viewBackerFundsFunction, blockParameter);
        }

        public Task<BigInteger> ViewCandidateFundsQueryAsync(ViewCandidateFundsFunction viewCandidateFundsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewCandidateFundsFunction, BigInteger>(viewCandidateFundsFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewCandidateFundsQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BigInteger candidateID, BlockParameter blockParameter = null)
        {
            var viewCandidateFundsFunction = new ViewCandidateFundsFunction();
                viewCandidateFundsFunction.RoundNumber = roundNumber;
                viewCandidateFundsFunction.LevelNumber = levelNumber;
                viewCandidateFundsFunction.CandidateID = candidateID;
            
            return ContractHandler.QueryAsync<ViewCandidateFundsFunction, BigInteger>(viewCandidateFundsFunction, blockParameter);
        }

        public Task<ViewElectionOutputDTO> ViewElectionQueryAsync(ViewElectionFunction viewElectionFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewElectionFunction, ViewElectionOutputDTO>(viewElectionFunction, blockParameter);
        }

        public Task<ViewElectionOutputDTO> ViewElectionQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BlockParameter blockParameter = null)
        {
            var viewElectionFunction = new ViewElectionFunction();
                viewElectionFunction.RoundNumber = roundNumber;
                viewElectionFunction.LevelNumber = levelNumber;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewElectionFunction, ViewElectionOutputDTO>(viewElectionFunction, blockParameter);
        }

        public Task<ViewLevelOutputDTO> ViewLevelQueryAsync(ViewLevelFunction viewLevelFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewLevelFunction, ViewLevelOutputDTO>(viewLevelFunction, blockParameter);
        }

        public Task<ViewLevelOutputDTO> ViewLevelQueryAsync(BigInteger roundNumber, BigInteger levelNumber, BlockParameter blockParameter = null)
        {
            var viewLevelFunction = new ViewLevelFunction();
                viewLevelFunction.RoundNumber = roundNumber;
                viewLevelFunction.LevelNumber = levelNumber;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewLevelFunction, ViewLevelOutputDTO>(viewLevelFunction, blockParameter);
        }

        public Task<BigInteger> ViewRoundNumberQueryAsync(ViewRoundNumberFunction viewRoundNumberFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewRoundNumberFunction, BigInteger>(viewRoundNumberFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewRoundNumberQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewRoundNumberFunction, BigInteger>(null, blockParameter);
        }
    }
}
