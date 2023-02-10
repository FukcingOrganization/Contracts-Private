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
using Contracts.Contracts.Community.ContractDefinition;

namespace Contracts.Contracts.Community
{
    public partial class CommunityService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, CommunityDeployment communityDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<CommunityDeployment>().SendRequestAndWaitForReceiptAsync(communityDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, CommunityDeployment communityDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<CommunityDeployment>().SendRequestAsync(communityDeployment);
        }

        public static async Task<CommunityService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, CommunityDeployment communityDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, communityDeployment, cancellationTokenSource);
            return new CommunityService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public CommunityService(Nethereum.Web3.Web3 web3, string contractAddress)
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

        public Task<string> ClaimMerkleRewardRequestAsync(ClaimMerkleRewardFunction claimMerkleRewardFunction)
        {
             return ContractHandler.SendRequestAsync(claimMerkleRewardFunction);
        }

        public Task<TransactionReceipt> ClaimMerkleRewardRequestAndWaitForReceiptAsync(ClaimMerkleRewardFunction claimMerkleRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimMerkleRewardFunction, cancellationToken);
        }

        public Task<string> ClaimMerkleRewardRequestAsync(BigInteger proposalID, List<byte[]> merkleProof)
        {
            var claimMerkleRewardFunction = new ClaimMerkleRewardFunction();
                claimMerkleRewardFunction.ProposalID = proposalID;
                claimMerkleRewardFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAsync(claimMerkleRewardFunction);
        }

        public Task<TransactionReceipt> ClaimMerkleRewardRequestAndWaitForReceiptAsync(BigInteger proposalID, List<byte[]> merkleProof, CancellationTokenSource cancellationToken = null)
        {
            var claimMerkleRewardFunction = new ClaimMerkleRewardFunction();
                claimMerkleRewardFunction.ProposalID = proposalID;
                claimMerkleRewardFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimMerkleRewardFunction, cancellationToken);
        }

        public Task<string> ClaimRewardRequestAsync(ClaimRewardFunction claimRewardFunction)
        {
             return ContractHandler.SendRequestAsync(claimRewardFunction);
        }

        public Task<TransactionReceipt> ClaimRewardRequestAndWaitForReceiptAsync(ClaimRewardFunction claimRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardFunction, cancellationToken);
        }

        public Task<string> ClaimRewardRequestAsync(BigInteger proposalID)
        {
            var claimRewardFunction = new ClaimRewardFunction();
                claimRewardFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(claimRewardFunction);
        }

        public Task<TransactionReceipt> ClaimRewardRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var claimRewardFunction = new ClaimRewardFunction();
                claimRewardFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardFunction, cancellationToken);
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

        public Task<string> ExecuteExtremeRewardLimitSetProposalRequestAsync(ExecuteExtremeRewardLimitSetProposalFunction executeExtremeRewardLimitSetProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeExtremeRewardLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteExtremeRewardLimitSetProposalRequestAndWaitForReceiptAsync(ExecuteExtremeRewardLimitSetProposalFunction executeExtremeRewardLimitSetProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeExtremeRewardLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteExtremeRewardLimitSetProposalRequestAsync(BigInteger proposalID)
        {
            var executeExtremeRewardLimitSetProposalFunction = new ExecuteExtremeRewardLimitSetProposalFunction();
                executeExtremeRewardLimitSetProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeExtremeRewardLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteExtremeRewardLimitSetProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeExtremeRewardLimitSetProposalFunction = new ExecuteExtremeRewardLimitSetProposalFunction();
                executeExtremeRewardLimitSetProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeExtremeRewardLimitSetProposalFunction, cancellationToken);
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

        public Task<string> ExecuteHighRewarLimitSetProposalRequestAsync(ExecuteHighRewarLimitSetProposalFunction executeHighRewarLimitSetProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeHighRewarLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteHighRewarLimitSetProposalRequestAndWaitForReceiptAsync(ExecuteHighRewarLimitSetProposalFunction executeHighRewarLimitSetProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeHighRewarLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteHighRewarLimitSetProposalRequestAsync(BigInteger proposalID)
        {
            var executeHighRewarLimitSetProposalFunction = new ExecuteHighRewarLimitSetProposalFunction();
                executeHighRewarLimitSetProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeHighRewarLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteHighRewarLimitSetProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeHighRewarLimitSetProposalFunction = new ExecuteHighRewarLimitSetProposalFunction();
                executeHighRewarLimitSetProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeHighRewarLimitSetProposalFunction, cancellationToken);
        }

        public Task<BigInteger> ExtremeRewardLimitQueryAsync(ExtremeRewardLimitFunction extremeRewardLimitFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ExtremeRewardLimitFunction, BigInteger>(extremeRewardLimitFunction, blockParameter);
        }

        
        public Task<BigInteger> ExtremeRewardLimitQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ExtremeRewardLimitFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> FunctionsProposalTypesQueryAsync(FunctionsProposalTypesFunction functionsProposalTypesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<FunctionsProposalTypesFunction, BigInteger>(functionsProposalTypesFunction, blockParameter);
        }

        
        public Task<BigInteger> FunctionsProposalTypesQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var functionsProposalTypesFunction = new FunctionsProposalTypesFunction();
                functionsProposalTypesFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<FunctionsProposalTypesFunction, BigInteger>(functionsProposalTypesFunction, blockParameter);
        }

        public Task<BigInteger> HighRewardLimitQueryAsync(HighRewardLimitFunction highRewardLimitFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<HighRewardLimitFunction, BigInteger>(highRewardLimitFunction, blockParameter);
        }

        
        public Task<BigInteger> HighRewardLimitQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<HighRewardLimitFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> IncreaseReceivedBalanceRequestAsync(IncreaseReceivedBalanceFunction increaseReceivedBalanceFunction)
        {
             return ContractHandler.SendRequestAsync(increaseReceivedBalanceFunction);
        }

        public Task<TransactionReceipt> IncreaseReceivedBalanceRequestAndWaitForReceiptAsync(IncreaseReceivedBalanceFunction increaseReceivedBalanceFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(increaseReceivedBalanceFunction, cancellationToken);
        }

        public Task<string> IncreaseReceivedBalanceRequestAsync(BigInteger amount)
        {
            var increaseReceivedBalanceFunction = new IncreaseReceivedBalanceFunction();
                increaseReceivedBalanceFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(increaseReceivedBalanceFunction);
        }

        public Task<TransactionReceipt> IncreaseReceivedBalanceRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var increaseReceivedBalanceFunction = new IncreaseReceivedBalanceFunction();
                increaseReceivedBalanceFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(increaseReceivedBalanceFunction, cancellationToken);
        }

        public Task<MerkleRewardsOutputDTO> MerkleRewardsQueryAsync(MerkleRewardsFunction merkleRewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<MerkleRewardsFunction, MerkleRewardsOutputDTO>(merkleRewardsFunction, blockParameter);
        }

        public Task<MerkleRewardsOutputDTO> MerkleRewardsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var merkleRewardsFunction = new MerkleRewardsFunction();
                merkleRewardsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<MerkleRewardsFunction, MerkleRewardsOutputDTO>(merkleRewardsFunction, blockParameter);
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

        public Task<string> ProposeExtremeRewardLimitSetRequestAsync(ProposeExtremeRewardLimitSetFunction proposeExtremeRewardLimitSetFunction)
        {
             return ContractHandler.SendRequestAsync(proposeExtremeRewardLimitSetFunction);
        }

        public Task<TransactionReceipt> ProposeExtremeRewardLimitSetRequestAndWaitForReceiptAsync(ProposeExtremeRewardLimitSetFunction proposeExtremeRewardLimitSetFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeExtremeRewardLimitSetFunction, cancellationToken);
        }

        public Task<string> ProposeExtremeRewardLimitSetRequestAsync(BigInteger newLimit)
        {
            var proposeExtremeRewardLimitSetFunction = new ProposeExtremeRewardLimitSetFunction();
                proposeExtremeRewardLimitSetFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAsync(proposeExtremeRewardLimitSetFunction);
        }

        public Task<TransactionReceipt> ProposeExtremeRewardLimitSetRequestAndWaitForReceiptAsync(BigInteger newLimit, CancellationTokenSource cancellationToken = null)
        {
            var proposeExtremeRewardLimitSetFunction = new ProposeExtremeRewardLimitSetFunction();
                proposeExtremeRewardLimitSetFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeExtremeRewardLimitSetFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(BigInteger functionIndex, BigInteger newIndex)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.FunctionIndex = functionIndex;
                proposeFunctionsProposalTypesUpdateFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(BigInteger functionIndex, BigInteger newIndex, CancellationTokenSource cancellationToken = null)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.FunctionIndex = functionIndex;
                proposeFunctionsProposalTypesUpdateFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeHighRewarLimitSetRequestAsync(ProposeHighRewarLimitSetFunction proposeHighRewarLimitSetFunction)
        {
             return ContractHandler.SendRequestAsync(proposeHighRewarLimitSetFunction);
        }

        public Task<TransactionReceipt> ProposeHighRewarLimitSetRequestAndWaitForReceiptAsync(ProposeHighRewarLimitSetFunction proposeHighRewarLimitSetFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeHighRewarLimitSetFunction, cancellationToken);
        }

        public Task<string> ProposeHighRewarLimitSetRequestAsync(BigInteger newLimit)
        {
            var proposeHighRewarLimitSetFunction = new ProposeHighRewarLimitSetFunction();
                proposeHighRewarLimitSetFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAsync(proposeHighRewarLimitSetFunction);
        }

        public Task<TransactionReceipt> ProposeHighRewarLimitSetRequestAndWaitForReceiptAsync(BigInteger newLimit, CancellationTokenSource cancellationToken = null)
        {
            var proposeHighRewarLimitSetFunction = new ProposeHighRewarLimitSetFunction();
                proposeHighRewarLimitSetFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeHighRewarLimitSetFunction, cancellationToken);
        }

        public Task<string> ProposeMerkleRewardRequestAsync(ProposeMerkleRewardFunction proposeMerkleRewardFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMerkleRewardFunction);
        }

        public Task<TransactionReceipt> ProposeMerkleRewardRequestAndWaitForReceiptAsync(ProposeMerkleRewardFunction proposeMerkleRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMerkleRewardFunction, cancellationToken);
        }

        public Task<string> ProposeMerkleRewardRequestAsync(List<byte[]> roots, List<BigInteger> rewards, BigInteger totalReward)
        {
            var proposeMerkleRewardFunction = new ProposeMerkleRewardFunction();
                proposeMerkleRewardFunction.Roots = roots;
                proposeMerkleRewardFunction.Rewards = rewards;
                proposeMerkleRewardFunction.TotalReward = totalReward;
            
             return ContractHandler.SendRequestAsync(proposeMerkleRewardFunction);
        }

        public Task<TransactionReceipt> ProposeMerkleRewardRequestAndWaitForReceiptAsync(List<byte[]> roots, List<BigInteger> rewards, BigInteger totalReward, CancellationTokenSource cancellationToken = null)
        {
            var proposeMerkleRewardFunction = new ProposeMerkleRewardFunction();
                proposeMerkleRewardFunction.Roots = roots;
                proposeMerkleRewardFunction.Rewards = rewards;
                proposeMerkleRewardFunction.TotalReward = totalReward;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMerkleRewardFunction, cancellationToken);
        }

        public Task<string> ProposeRewardRequestAsync(ProposeRewardFunction proposeRewardFunction)
        {
             return ContractHandler.SendRequestAsync(proposeRewardFunction);
        }

        public Task<TransactionReceipt> ProposeRewardRequestAndWaitForReceiptAsync(ProposeRewardFunction proposeRewardFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeRewardFunction, cancellationToken);
        }

        public Task<string> ProposeRewardRequestAsync(List<string> receivers, List<BigInteger> rewards)
        {
            var proposeRewardFunction = new ProposeRewardFunction();
                proposeRewardFunction.Receivers = receivers;
                proposeRewardFunction.Rewards = rewards;
            
             return ContractHandler.SendRequestAsync(proposeRewardFunction);
        }

        public Task<TransactionReceipt> ProposeRewardRequestAndWaitForReceiptAsync(List<string> receivers, List<BigInteger> rewards, CancellationTokenSource cancellationToken = null)
        {
            var proposeRewardFunction = new ProposeRewardFunction();
                proposeRewardFunction.Receivers = receivers;
                proposeRewardFunction.Rewards = rewards;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeRewardFunction, cancellationToken);
        }

        public Task<BigInteger> ReceivedBalanceQueryAsync(ReceivedBalanceFunction receivedBalanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReceivedBalanceFunction, BigInteger>(receivedBalanceFunction, blockParameter);
        }

        
        public Task<BigInteger> ReceivedBalanceQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReceivedBalanceFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> ReservedBalanceQueryAsync(ReservedBalanceFunction reservedBalanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReservedBalanceFunction, BigInteger>(reservedBalanceFunction, blockParameter);
        }

        
        public Task<BigInteger> ReservedBalanceQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReservedBalanceFunction, BigInteger>(null, blockParameter);
        }

        public Task<RewardsOutputDTO> RewardsQueryAsync(RewardsFunction rewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<RewardsFunction, RewardsOutputDTO>(rewardsFunction, blockParameter);
        }

        public Task<RewardsOutputDTO> RewardsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var rewardsFunction = new RewardsFunction();
                rewardsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<RewardsFunction, RewardsOutputDTO>(rewardsFunction, blockParameter);
        }

        public Task<string> UpdateRewardStatusRequestAsync(UpdateRewardStatusFunction updateRewardStatusFunction)
        {
             return ContractHandler.SendRequestAsync(updateRewardStatusFunction);
        }

        public Task<TransactionReceipt> UpdateRewardStatusRequestAndWaitForReceiptAsync(UpdateRewardStatusFunction updateRewardStatusFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateRewardStatusFunction, cancellationToken);
        }

        public Task<string> UpdateRewardStatusRequestAsync(BigInteger proposalID)
        {
            var updateRewardStatusFunction = new UpdateRewardStatusFunction();
                updateRewardStatusFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(updateRewardStatusFunction);
        }

        public Task<TransactionReceipt> UpdateRewardStatusRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var updateRewardStatusFunction = new UpdateRewardStatusFunction();
                updateRewardStatusFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateRewardStatusFunction, cancellationToken);
        }
    }
}
