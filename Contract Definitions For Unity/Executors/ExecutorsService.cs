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
using Contracts.Contracts.Executors.ContractDefinition;

namespace Contracts.Contracts.Executors
{
    public partial class ExecutorsService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ExecutorsDeployment executorsDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ExecutorsDeployment>().SendRequestAndWaitForReceiptAsync(executorsDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ExecutorsDeployment executorsDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ExecutorsDeployment>().SendRequestAsync(executorsDeployment);
        }

        public static async Task<ExecutorsService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ExecutorsDeployment executorsDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, executorsDeployment, cancellationTokenSource);
            return new ExecutorsService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public ExecutorsService(Nethereum.Web3.Web3 web3, string contractAddress)
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

        public Task<byte[]> DEFAULT_ADMIN_ROLEQueryAsync(DEFAULT_ADMIN_ROLEFunction dEFAULT_ADMIN_ROLEFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DEFAULT_ADMIN_ROLEFunction, byte[]>(dEFAULT_ADMIN_ROLEFunction, blockParameter);
        }

        
        public Task<byte[]> DEFAULT_ADMIN_ROLEQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DEFAULT_ADMIN_ROLEFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> EXECUTOR_ROLEQueryAsync(EXECUTOR_ROLEFunction eXECUTOR_ROLEFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EXECUTOR_ROLEFunction, byte[]>(eXECUTOR_ROLEFunction, blockParameter);
        }

        
        public Task<byte[]> EXECUTOR_ROLEQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EXECUTOR_ROLEFunction, byte[]>(null, blockParameter);
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

        public Task<string> CreateBossMintCostUpdateProposalRequestAsync(CreateBossMintCostUpdateProposalFunction createBossMintCostUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createBossMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateBossMintCostUpdateProposalRequestAndWaitForReceiptAsync(CreateBossMintCostUpdateProposalFunction createBossMintCostUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createBossMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateBossMintCostUpdateProposalRequestAsync(BigInteger newCost)
        {
            var createBossMintCostUpdateProposalFunction = new CreateBossMintCostUpdateProposalFunction();
                createBossMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAsync(createBossMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateBossMintCostUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newCost, CancellationTokenSource cancellationToken = null)
        {
            var createBossMintCostUpdateProposalFunction = new CreateBossMintCostUpdateProposalFunction();
                createBossMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createBossMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanCooldownTimeUpdateProposalRequestAsync(CreateClanCooldownTimeUpdateProposalFunction createClanCooldownTimeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createClanCooldownTimeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanCooldownTimeUpdateProposalRequestAndWaitForReceiptAsync(CreateClanCooldownTimeUpdateProposalFunction createClanCooldownTimeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanCooldownTimeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanCooldownTimeUpdateProposalRequestAsync(BigInteger newCoolDownTime)
        {
            var createClanCooldownTimeUpdateProposalFunction = new CreateClanCooldownTimeUpdateProposalFunction();
                createClanCooldownTimeUpdateProposalFunction.NewCoolDownTime = newCoolDownTime;
            
             return ContractHandler.SendRequestAsync(createClanCooldownTimeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanCooldownTimeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newCoolDownTime, CancellationTokenSource cancellationToken = null)
        {
            var createClanCooldownTimeUpdateProposalFunction = new CreateClanCooldownTimeUpdateProposalFunction();
                createClanCooldownTimeUpdateProposalFunction.NewCoolDownTime = newCoolDownTime;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanCooldownTimeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanGiveBatchClanPointsRequestAsync(CreateClanGiveBatchClanPointsFunction createClanGiveBatchClanPointsFunction)
        {
             return ContractHandler.SendRequestAsync(createClanGiveBatchClanPointsFunction);
        }

        public Task<TransactionReceipt> CreateClanGiveBatchClanPointsRequestAndWaitForReceiptAsync(CreateClanGiveBatchClanPointsFunction createClanGiveBatchClanPointsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanGiveBatchClanPointsFunction, cancellationToken);
        }

        public Task<string> CreateClanGiveBatchClanPointsRequestAsync(List<BigInteger> clanIDs, List<BigInteger> points, List<bool> isDecreasing)
        {
            var createClanGiveBatchClanPointsFunction = new CreateClanGiveBatchClanPointsFunction();
                createClanGiveBatchClanPointsFunction.ClanIDs = clanIDs;
                createClanGiveBatchClanPointsFunction.Points = points;
                createClanGiveBatchClanPointsFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(createClanGiveBatchClanPointsFunction);
        }

        public Task<TransactionReceipt> CreateClanGiveBatchClanPointsRequestAndWaitForReceiptAsync(List<BigInteger> clanIDs, List<BigInteger> points, List<bool> isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var createClanGiveBatchClanPointsFunction = new CreateClanGiveBatchClanPointsFunction();
                createClanGiveBatchClanPointsFunction.ClanIDs = clanIDs;
                createClanGiveBatchClanPointsFunction.Points = points;
                createClanGiveBatchClanPointsFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanGiveBatchClanPointsFunction, cancellationToken);
        }

        public Task<string> CreateClanGiveClanPointRequestAsync(CreateClanGiveClanPointFunction createClanGiveClanPointFunction)
        {
             return ContractHandler.SendRequestAsync(createClanGiveClanPointFunction);
        }

        public Task<TransactionReceipt> CreateClanGiveClanPointRequestAndWaitForReceiptAsync(CreateClanGiveClanPointFunction createClanGiveClanPointFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanGiveClanPointFunction, cancellationToken);
        }

        public Task<string> CreateClanGiveClanPointRequestAsync(BigInteger clanID, BigInteger point, bool isDecreasing)
        {
            var createClanGiveClanPointFunction = new CreateClanGiveClanPointFunction();
                createClanGiveClanPointFunction.ClanID = clanID;
                createClanGiveClanPointFunction.Point = point;
                createClanGiveClanPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(createClanGiveClanPointFunction);
        }

        public Task<TransactionReceipt> CreateClanGiveClanPointRequestAndWaitForReceiptAsync(BigInteger clanID, BigInteger point, bool isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var createClanGiveClanPointFunction = new CreateClanGiveClanPointFunction();
                createClanGiveClanPointFunction.ClanID = clanID;
                createClanGiveClanPointFunction.Point = point;
                createClanGiveClanPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanGiveClanPointFunction, cancellationToken);
        }

        public Task<string> CreateClanLicenseMintCostUpdateProposalRequestAsync(CreateClanLicenseMintCostUpdateProposalFunction createClanLicenseMintCostUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createClanLicenseMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanLicenseMintCostUpdateProposalRequestAndWaitForReceiptAsync(CreateClanLicenseMintCostUpdateProposalFunction createClanLicenseMintCostUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanLicenseMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanLicenseMintCostUpdateProposalRequestAsync(BigInteger newCost)
        {
            var createClanLicenseMintCostUpdateProposalFunction = new CreateClanLicenseMintCostUpdateProposalFunction();
                createClanLicenseMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAsync(createClanLicenseMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanLicenseMintCostUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newCost, CancellationTokenSource cancellationToken = null)
        {
            var createClanLicenseMintCostUpdateProposalFunction = new CreateClanLicenseMintCostUpdateProposalFunction();
                createClanLicenseMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanLicenseMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanMaxPointToChangeUpdateProposalRequestAsync(CreateClanMaxPointToChangeUpdateProposalFunction createClanMaxPointToChangeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createClanMaxPointToChangeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanMaxPointToChangeUpdateProposalRequestAndWaitForReceiptAsync(CreateClanMaxPointToChangeUpdateProposalFunction createClanMaxPointToChangeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanMaxPointToChangeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanMaxPointToChangeUpdateProposalRequestAsync(BigInteger newMaxPoint)
        {
            var createClanMaxPointToChangeUpdateProposalFunction = new CreateClanMaxPointToChangeUpdateProposalFunction();
                createClanMaxPointToChangeUpdateProposalFunction.NewMaxPoint = newMaxPoint;
            
             return ContractHandler.SendRequestAsync(createClanMaxPointToChangeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanMaxPointToChangeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newMaxPoint, CancellationTokenSource cancellationToken = null)
        {
            var createClanMaxPointToChangeUpdateProposalFunction = new CreateClanMaxPointToChangeUpdateProposalFunction();
                createClanMaxPointToChangeUpdateProposalFunction.NewMaxPoint = newMaxPoint;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanMaxPointToChangeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanMinBalanceToPropClanPointUpdateProposalRequestAsync(CreateClanMinBalanceToPropClanPointUpdateProposalFunction createClanMinBalanceToPropClanPointUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createClanMinBalanceToPropClanPointUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanMinBalanceToPropClanPointUpdateProposalRequestAndWaitForReceiptAsync(CreateClanMinBalanceToPropClanPointUpdateProposalFunction createClanMinBalanceToPropClanPointUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanMinBalanceToPropClanPointUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateClanMinBalanceToPropClanPointUpdateProposalRequestAsync(BigInteger newAmount)
        {
            var createClanMinBalanceToPropClanPointUpdateProposalFunction = new CreateClanMinBalanceToPropClanPointUpdateProposalFunction();
                createClanMinBalanceToPropClanPointUpdateProposalFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAsync(createClanMinBalanceToPropClanPointUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateClanMinBalanceToPropClanPointUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newAmount, CancellationTokenSource cancellationToken = null)
        {
            var createClanMinBalanceToPropClanPointUpdateProposalFunction = new CreateClanMinBalanceToPropClanPointUpdateProposalFunction();
                createClanMinBalanceToPropClanPointUpdateProposalFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanMinBalanceToPropClanPointUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityExtremeRewardLimitSetProposalRequestAsync(CreateCommunityExtremeRewardLimitSetProposalFunction createCommunityExtremeRewardLimitSetProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createCommunityExtremeRewardLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityExtremeRewardLimitSetProposalRequestAndWaitForReceiptAsync(CreateCommunityExtremeRewardLimitSetProposalFunction createCommunityExtremeRewardLimitSetProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityExtremeRewardLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityExtremeRewardLimitSetProposalRequestAsync(BigInteger newLimit)
        {
            var createCommunityExtremeRewardLimitSetProposalFunction = new CreateCommunityExtremeRewardLimitSetProposalFunction();
                createCommunityExtremeRewardLimitSetProposalFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAsync(createCommunityExtremeRewardLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityExtremeRewardLimitSetProposalRequestAndWaitForReceiptAsync(BigInteger newLimit, CancellationTokenSource cancellationToken = null)
        {
            var createCommunityExtremeRewardLimitSetProposalFunction = new CreateCommunityExtremeRewardLimitSetProposalFunction();
                createCommunityExtremeRewardLimitSetProposalFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityExtremeRewardLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityHighRewarLimitSetProposalRequestAsync(CreateCommunityHighRewarLimitSetProposalFunction createCommunityHighRewarLimitSetProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createCommunityHighRewarLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityHighRewarLimitSetProposalRequestAndWaitForReceiptAsync(CreateCommunityHighRewarLimitSetProposalFunction createCommunityHighRewarLimitSetProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityHighRewarLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityHighRewarLimitSetProposalRequestAsync(BigInteger newLimit)
        {
            var createCommunityHighRewarLimitSetProposalFunction = new CreateCommunityHighRewarLimitSetProposalFunction();
                createCommunityHighRewarLimitSetProposalFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAsync(createCommunityHighRewarLimitSetProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityHighRewarLimitSetProposalRequestAndWaitForReceiptAsync(BigInteger newLimit, CancellationTokenSource cancellationToken = null)
        {
            var createCommunityHighRewarLimitSetProposalFunction = new CreateCommunityHighRewarLimitSetProposalFunction();
                createCommunityHighRewarLimitSetProposalFunction.NewLimit = newLimit;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityHighRewarLimitSetProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityMerkleRewardProposalRequestAsync(CreateCommunityMerkleRewardProposalFunction createCommunityMerkleRewardProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createCommunityMerkleRewardProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityMerkleRewardProposalRequestAndWaitForReceiptAsync(CreateCommunityMerkleRewardProposalFunction createCommunityMerkleRewardProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityMerkleRewardProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityMerkleRewardProposalRequestAsync(List<byte[]> roots, List<BigInteger> rewards, BigInteger totalReward)
        {
            var createCommunityMerkleRewardProposalFunction = new CreateCommunityMerkleRewardProposalFunction();
                createCommunityMerkleRewardProposalFunction.Roots = roots;
                createCommunityMerkleRewardProposalFunction.Rewards = rewards;
                createCommunityMerkleRewardProposalFunction.TotalReward = totalReward;
            
             return ContractHandler.SendRequestAsync(createCommunityMerkleRewardProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityMerkleRewardProposalRequestAndWaitForReceiptAsync(List<byte[]> roots, List<BigInteger> rewards, BigInteger totalReward, CancellationTokenSource cancellationToken = null)
        {
            var createCommunityMerkleRewardProposalFunction = new CreateCommunityMerkleRewardProposalFunction();
                createCommunityMerkleRewardProposalFunction.Roots = roots;
                createCommunityMerkleRewardProposalFunction.Rewards = rewards;
                createCommunityMerkleRewardProposalFunction.TotalReward = totalReward;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityMerkleRewardProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityRewardProposalRequestAsync(CreateCommunityRewardProposalFunction createCommunityRewardProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createCommunityRewardProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityRewardProposalRequestAndWaitForReceiptAsync(CreateCommunityRewardProposalFunction createCommunityRewardProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityRewardProposalFunction, cancellationToken);
        }

        public Task<string> CreateCommunityRewardProposalRequestAsync(List<string> receivers, List<BigInteger> rewards)
        {
            var createCommunityRewardProposalFunction = new CreateCommunityRewardProposalFunction();
                createCommunityRewardProposalFunction.Receivers = receivers;
                createCommunityRewardProposalFunction.Rewards = rewards;
            
             return ContractHandler.SendRequestAsync(createCommunityRewardProposalFunction);
        }

        public Task<TransactionReceipt> CreateCommunityRewardProposalRequestAndWaitForReceiptAsync(List<string> receivers, List<BigInteger> rewards, CancellationTokenSource cancellationToken = null)
        {
            var createCommunityRewardProposalFunction = new CreateCommunityRewardProposalFunction();
                createCommunityRewardProposalFunction.Receivers = receivers;
                createCommunityRewardProposalFunction.Rewards = rewards;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createCommunityRewardProposalFunction, cancellationToken);
        }

        public Task<string> CreateContractAddressUpdateProposalRequestAsync(CreateContractAddressUpdateProposalFunction createContractAddressUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createContractAddressUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateContractAddressUpdateProposalRequestAndWaitForReceiptAsync(CreateContractAddressUpdateProposalFunction createContractAddressUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createContractAddressUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateContractAddressUpdateProposalRequestAsync(BigInteger contractIndex, BigInteger subjectIndex, string newAddress)
        {
            var createContractAddressUpdateProposalFunction = new CreateContractAddressUpdateProposalFunction();
                createContractAddressUpdateProposalFunction.ContractIndex = contractIndex;
                createContractAddressUpdateProposalFunction.SubjectIndex = subjectIndex;
                createContractAddressUpdateProposalFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAsync(createContractAddressUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateContractAddressUpdateProposalRequestAndWaitForReceiptAsync(BigInteger contractIndex, BigInteger subjectIndex, string newAddress, CancellationTokenSource cancellationToken = null)
        {
            var createContractAddressUpdateProposalFunction = new CreateContractAddressUpdateProposalFunction();
                createContractAddressUpdateProposalFunction.ContractIndex = contractIndex;
                createContractAddressUpdateProposalFunction.SubjectIndex = subjectIndex;
                createContractAddressUpdateProposalFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createContractAddressUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAOMinBalanceToPropUpdateProposalRequestAsync(CreateDAOMinBalanceToPropUpdateProposalFunction createDAOMinBalanceToPropUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createDAOMinBalanceToPropUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAOMinBalanceToPropUpdateProposalRequestAndWaitForReceiptAsync(CreateDAOMinBalanceToPropUpdateProposalFunction createDAOMinBalanceToPropUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAOMinBalanceToPropUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAOMinBalanceToPropUpdateProposalRequestAsync(BigInteger newAmount)
        {
            var createDAOMinBalanceToPropUpdateProposalFunction = new CreateDAOMinBalanceToPropUpdateProposalFunction();
                createDAOMinBalanceToPropUpdateProposalFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAsync(createDAOMinBalanceToPropUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAOMinBalanceToPropUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newAmount, CancellationTokenSource cancellationToken = null)
        {
            var createDAOMinBalanceToPropUpdateProposalFunction = new CreateDAOMinBalanceToPropUpdateProposalFunction();
                createDAOMinBalanceToPropUpdateProposalFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAOMinBalanceToPropUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewCoinSpendingProposalRequestAsync(CreateDAONewCoinSpendingProposalFunction createDAONewCoinSpendingProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createDAONewCoinSpendingProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewCoinSpendingProposalRequestAndWaitForReceiptAsync(CreateDAONewCoinSpendingProposalFunction createDAONewCoinSpendingProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewCoinSpendingProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewCoinSpendingProposalRequestAsync(List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending)
        {
            var createDAONewCoinSpendingProposalFunction = new CreateDAONewCoinSpendingProposalFunction();
                createDAONewCoinSpendingProposalFunction.MerkleRoots = merkleRoots;
                createDAONewCoinSpendingProposalFunction.Allowances = allowances;
                createDAONewCoinSpendingProposalFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAsync(createDAONewCoinSpendingProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewCoinSpendingProposalRequestAndWaitForReceiptAsync(List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending, CancellationTokenSource cancellationToken = null)
        {
            var createDAONewCoinSpendingProposalFunction = new CreateDAONewCoinSpendingProposalFunction();
                createDAONewCoinSpendingProposalFunction.MerkleRoots = merkleRoots;
                createDAONewCoinSpendingProposalFunction.Allowances = allowances;
                createDAONewCoinSpendingProposalFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewCoinSpendingProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewProposalTypeProposalRequestAsync(CreateDAONewProposalTypeProposalFunction createDAONewProposalTypeProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createDAONewProposalTypeProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewProposalTypeProposalRequestAndWaitForReceiptAsync(CreateDAONewProposalTypeProposalFunction createDAONewProposalTypeProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewProposalTypeProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewProposalTypeProposalRequestAsync(BigInteger length, BigInteger requiredApprovalRate, BigInteger requiredTokenAmount, BigInteger requiredParticipantAmount)
        {
            var createDAONewProposalTypeProposalFunction = new CreateDAONewProposalTypeProposalFunction();
                createDAONewProposalTypeProposalFunction.Length = length;
                createDAONewProposalTypeProposalFunction.RequiredApprovalRate = requiredApprovalRate;
                createDAONewProposalTypeProposalFunction.RequiredTokenAmount = requiredTokenAmount;
                createDAONewProposalTypeProposalFunction.RequiredParticipantAmount = requiredParticipantAmount;
            
             return ContractHandler.SendRequestAsync(createDAONewProposalTypeProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewProposalTypeProposalRequestAndWaitForReceiptAsync(BigInteger length, BigInteger requiredApprovalRate, BigInteger requiredTokenAmount, BigInteger requiredParticipantAmount, CancellationTokenSource cancellationToken = null)
        {
            var createDAONewProposalTypeProposalFunction = new CreateDAONewProposalTypeProposalFunction();
                createDAONewProposalTypeProposalFunction.Length = length;
                createDAONewProposalTypeProposalFunction.RequiredApprovalRate = requiredApprovalRate;
                createDAONewProposalTypeProposalFunction.RequiredTokenAmount = requiredTokenAmount;
                createDAONewProposalTypeProposalFunction.RequiredParticipantAmount = requiredParticipantAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewProposalTypeProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewTokenSpendingProposalRequestAsync(CreateDAONewTokenSpendingProposalFunction createDAONewTokenSpendingProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createDAONewTokenSpendingProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewTokenSpendingProposalRequestAndWaitForReceiptAsync(CreateDAONewTokenSpendingProposalFunction createDAONewTokenSpendingProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewTokenSpendingProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAONewTokenSpendingProposalRequestAsync(string tokenContractAddress, List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending)
        {
            var createDAONewTokenSpendingProposalFunction = new CreateDAONewTokenSpendingProposalFunction();
                createDAONewTokenSpendingProposalFunction.TokenContractAddress = tokenContractAddress;
                createDAONewTokenSpendingProposalFunction.MerkleRoots = merkleRoots;
                createDAONewTokenSpendingProposalFunction.Allowances = allowances;
                createDAONewTokenSpendingProposalFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAsync(createDAONewTokenSpendingProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAONewTokenSpendingProposalRequestAndWaitForReceiptAsync(string tokenContractAddress, List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending, CancellationTokenSource cancellationToken = null)
        {
            var createDAONewTokenSpendingProposalFunction = new CreateDAONewTokenSpendingProposalFunction();
                createDAONewTokenSpendingProposalFunction.TokenContractAddress = tokenContractAddress;
                createDAONewTokenSpendingProposalFunction.MerkleRoots = merkleRoots;
                createDAONewTokenSpendingProposalFunction.Allowances = allowances;
                createDAONewTokenSpendingProposalFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAONewTokenSpendingProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAOProposalTypeUpdateProposalRequestAsync(CreateDAOProposalTypeUpdateProposalFunction createDAOProposalTypeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createDAOProposalTypeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAOProposalTypeUpdateProposalRequestAndWaitForReceiptAsync(CreateDAOProposalTypeUpdateProposalFunction createDAOProposalTypeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAOProposalTypeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateDAOProposalTypeUpdateProposalRequestAsync(BigInteger proposalTypeNumber, BigInteger newLength, BigInteger newRequiredApprovalRate, BigInteger newRequiredTokenAmount, BigInteger newRequiredParticipantAmount)
        {
            var createDAOProposalTypeUpdateProposalFunction = new CreateDAOProposalTypeUpdateProposalFunction();
                createDAOProposalTypeUpdateProposalFunction.ProposalTypeNumber = proposalTypeNumber;
                createDAOProposalTypeUpdateProposalFunction.NewLength = newLength;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredApprovalRate = newRequiredApprovalRate;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredTokenAmount = newRequiredTokenAmount;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredParticipantAmount = newRequiredParticipantAmount;
            
             return ContractHandler.SendRequestAsync(createDAOProposalTypeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateDAOProposalTypeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalTypeNumber, BigInteger newLength, BigInteger newRequiredApprovalRate, BigInteger newRequiredTokenAmount, BigInteger newRequiredParticipantAmount, CancellationTokenSource cancellationToken = null)
        {
            var createDAOProposalTypeUpdateProposalFunction = new CreateDAOProposalTypeUpdateProposalFunction();
                createDAOProposalTypeUpdateProposalFunction.ProposalTypeNumber = proposalTypeNumber;
                createDAOProposalTypeUpdateProposalFunction.NewLength = newLength;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredApprovalRate = newRequiredApprovalRate;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredTokenAmount = newRequiredTokenAmount;
                createDAOProposalTypeUpdateProposalFunction.NewRequiredParticipantAmount = newRequiredParticipantAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createDAOProposalTypeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateFunctionsProposalTypesUpdateProposalRequestAsync(CreateFunctionsProposalTypesUpdateProposalFunction createFunctionsProposalTypesUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createFunctionsProposalTypesUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateFunctionsProposalTypesUpdateProposalRequestAndWaitForReceiptAsync(CreateFunctionsProposalTypesUpdateProposalFunction createFunctionsProposalTypesUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createFunctionsProposalTypesUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateFunctionsProposalTypesUpdateProposalRequestAsync(BigInteger contractIndex, BigInteger subjectIndex, BigInteger newIndex)
        {
            var createFunctionsProposalTypesUpdateProposalFunction = new CreateFunctionsProposalTypesUpdateProposalFunction();
                createFunctionsProposalTypesUpdateProposalFunction.ContractIndex = contractIndex;
                createFunctionsProposalTypesUpdateProposalFunction.SubjectIndex = subjectIndex;
                createFunctionsProposalTypesUpdateProposalFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAsync(createFunctionsProposalTypesUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateFunctionsProposalTypesUpdateProposalRequestAndWaitForReceiptAsync(BigInteger contractIndex, BigInteger subjectIndex, BigInteger newIndex, CancellationTokenSource cancellationToken = null)
        {
            var createFunctionsProposalTypesUpdateProposalFunction = new CreateFunctionsProposalTypesUpdateProposalFunction();
                createFunctionsProposalTypesUpdateProposalFunction.ContractIndex = contractIndex;
                createFunctionsProposalTypesUpdateProposalFunction.SubjectIndex = subjectIndex;
                createFunctionsProposalTypesUpdateProposalFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createFunctionsProposalTypesUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateItemActivationUpdateProposalRequestAsync(CreateItemActivationUpdateProposalFunction createItemActivationUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createItemActivationUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateItemActivationUpdateProposalRequestAndWaitForReceiptAsync(CreateItemActivationUpdateProposalFunction createItemActivationUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemActivationUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateItemActivationUpdateProposalRequestAsync(BigInteger itemID, bool activationStatus)
        {
            var createItemActivationUpdateProposalFunction = new CreateItemActivationUpdateProposalFunction();
                createItemActivationUpdateProposalFunction.ItemID = itemID;
                createItemActivationUpdateProposalFunction.ActivationStatus = activationStatus;
            
             return ContractHandler.SendRequestAsync(createItemActivationUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateItemActivationUpdateProposalRequestAndWaitForReceiptAsync(BigInteger itemID, bool activationStatus, CancellationTokenSource cancellationToken = null)
        {
            var createItemActivationUpdateProposalFunction = new CreateItemActivationUpdateProposalFunction();
                createItemActivationUpdateProposalFunction.ItemID = itemID;
                createItemActivationUpdateProposalFunction.ActivationStatus = activationStatus;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemActivationUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateItemSetNewTokenURIRequestAsync(CreateItemSetNewTokenURIFunction createItemSetNewTokenURIFunction)
        {
             return ContractHandler.SendRequestAsync(createItemSetNewTokenURIFunction);
        }

        public Task<TransactionReceipt> CreateItemSetNewTokenURIRequestAndWaitForReceiptAsync(CreateItemSetNewTokenURIFunction createItemSetNewTokenURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemSetNewTokenURIFunction, cancellationToken);
        }

        public Task<string> CreateItemSetNewTokenURIRequestAsync(BigInteger tokenID, string newURI)
        {
            var createItemSetNewTokenURIFunction = new CreateItemSetNewTokenURIFunction();
                createItemSetNewTokenURIFunction.TokenID = tokenID;
                createItemSetNewTokenURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAsync(createItemSetNewTokenURIFunction);
        }

        public Task<TransactionReceipt> CreateItemSetNewTokenURIRequestAndWaitForReceiptAsync(BigInteger tokenID, string newURI, CancellationTokenSource cancellationToken = null)
        {
            var createItemSetNewTokenURIFunction = new CreateItemSetNewTokenURIFunction();
                createItemSetNewTokenURIFunction.TokenID = tokenID;
                createItemSetNewTokenURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemSetNewTokenURIFunction, cancellationToken);
        }

        public Task<string> CreateItemsMintCostUpdateProposalRequestAsync(CreateItemsMintCostUpdateProposalFunction createItemsMintCostUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createItemsMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateItemsMintCostUpdateProposalRequestAndWaitForReceiptAsync(CreateItemsMintCostUpdateProposalFunction createItemsMintCostUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemsMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateItemsMintCostUpdateProposalRequestAsync(BigInteger itemID, BigInteger newCost)
        {
            var createItemsMintCostUpdateProposalFunction = new CreateItemsMintCostUpdateProposalFunction();
                createItemsMintCostUpdateProposalFunction.ItemID = itemID;
                createItemsMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAsync(createItemsMintCostUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateItemsMintCostUpdateProposalRequestAndWaitForReceiptAsync(BigInteger itemID, BigInteger newCost, CancellationTokenSource cancellationToken = null)
        {
            var createItemsMintCostUpdateProposalFunction = new CreateItemsMintCostUpdateProposalFunction();
                createItemsMintCostUpdateProposalFunction.ItemID = itemID;
                createItemsMintCostUpdateProposalFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createItemsMintCostUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordBaseTaxRateUpdateProposalRequestAsync(CreateLordBaseTaxRateUpdateProposalFunction createLordBaseTaxRateUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordBaseTaxRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordBaseTaxRateUpdateProposalRequestAndWaitForReceiptAsync(CreateLordBaseTaxRateUpdateProposalFunction createLordBaseTaxRateUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordBaseTaxRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordBaseTaxRateUpdateProposalRequestAsync(BigInteger newBaseTaxRate)
        {
            var createLordBaseTaxRateUpdateProposalFunction = new CreateLordBaseTaxRateUpdateProposalFunction();
                createLordBaseTaxRateUpdateProposalFunction.NewBaseTaxRate = newBaseTaxRate;
            
             return ContractHandler.SendRequestAsync(createLordBaseTaxRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordBaseTaxRateUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newBaseTaxRate, CancellationTokenSource cancellationToken = null)
        {
            var createLordBaseTaxRateUpdateProposalFunction = new CreateLordBaseTaxRateUpdateProposalFunction();
                createLordBaseTaxRateUpdateProposalFunction.NewBaseTaxRate = newBaseTaxRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordBaseTaxRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordRebellionLengthUpdateProposalRequestAsync(CreateLordRebellionLengthUpdateProposalFunction createLordRebellionLengthUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordRebellionLengthUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordRebellionLengthUpdateProposalRequestAndWaitForReceiptAsync(CreateLordRebellionLengthUpdateProposalFunction createLordRebellionLengthUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordRebellionLengthUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordRebellionLengthUpdateProposalRequestAsync(BigInteger newRebellionLength)
        {
            var createLordRebellionLengthUpdateProposalFunction = new CreateLordRebellionLengthUpdateProposalFunction();
                createLordRebellionLengthUpdateProposalFunction.NewRebellionLength = newRebellionLength;
            
             return ContractHandler.SendRequestAsync(createLordRebellionLengthUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordRebellionLengthUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newRebellionLength, CancellationTokenSource cancellationToken = null)
        {
            var createLordRebellionLengthUpdateProposalFunction = new CreateLordRebellionLengthUpdateProposalFunction();
                createLordRebellionLengthUpdateProposalFunction.NewRebellionLength = newRebellionLength;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordRebellionLengthUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordSetBaseURIRequestAsync(CreateLordSetBaseURIFunction createLordSetBaseURIFunction)
        {
             return ContractHandler.SendRequestAsync(createLordSetBaseURIFunction);
        }

        public Task<TransactionReceipt> CreateLordSetBaseURIRequestAndWaitForReceiptAsync(CreateLordSetBaseURIFunction createLordSetBaseURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordSetBaseURIFunction, cancellationToken);
        }

        public Task<string> CreateLordSetBaseURIRequestAsync(string newURI)
        {
            var createLordSetBaseURIFunction = new CreateLordSetBaseURIFunction();
                createLordSetBaseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAsync(createLordSetBaseURIFunction);
        }

        public Task<TransactionReceipt> CreateLordSetBaseURIRequestAndWaitForReceiptAsync(string newURI, CancellationTokenSource cancellationToken = null)
        {
            var createLordSetBaseURIFunction = new CreateLordSetBaseURIFunction();
                createLordSetBaseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordSetBaseURIFunction, cancellationToken);
        }

        public Task<string> CreateLordSignalLengthUpdateProposalRequestAsync(CreateLordSignalLengthUpdateProposalFunction createLordSignalLengthUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordSignalLengthUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordSignalLengthUpdateProposalRequestAndWaitForReceiptAsync(CreateLordSignalLengthUpdateProposalFunction createLordSignalLengthUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordSignalLengthUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordSignalLengthUpdateProposalRequestAsync(BigInteger newSignalLength)
        {
            var createLordSignalLengthUpdateProposalFunction = new CreateLordSignalLengthUpdateProposalFunction();
                createLordSignalLengthUpdateProposalFunction.NewSignalLength = newSignalLength;
            
             return ContractHandler.SendRequestAsync(createLordSignalLengthUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordSignalLengthUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newSignalLength, CancellationTokenSource cancellationToken = null)
        {
            var createLordSignalLengthUpdateProposalFunction = new CreateLordSignalLengthUpdateProposalFunction();
                createLordSignalLengthUpdateProposalFunction.NewSignalLength = newSignalLength;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordSignalLengthUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordTaxChangeRateUpdateProposalRequestAsync(CreateLordTaxChangeRateUpdateProposalFunction createLordTaxChangeRateUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordTaxChangeRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordTaxChangeRateUpdateProposalRequestAndWaitForReceiptAsync(CreateLordTaxChangeRateUpdateProposalFunction createLordTaxChangeRateUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordTaxChangeRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordTaxChangeRateUpdateProposalRequestAsync(BigInteger newTaxChangeRate)
        {
            var createLordTaxChangeRateUpdateProposalFunction = new CreateLordTaxChangeRateUpdateProposalFunction();
                createLordTaxChangeRateUpdateProposalFunction.NewTaxChangeRate = newTaxChangeRate;
            
             return ContractHandler.SendRequestAsync(createLordTaxChangeRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordTaxChangeRateUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newTaxChangeRate, CancellationTokenSource cancellationToken = null)
        {
            var createLordTaxChangeRateUpdateProposalFunction = new CreateLordTaxChangeRateUpdateProposalFunction();
                createLordTaxChangeRateUpdateProposalFunction.NewTaxChangeRate = newTaxChangeRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordTaxChangeRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordVictoryRateUpdateProposalRequestAsync(CreateLordVictoryRateUpdateProposalFunction createLordVictoryRateUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordVictoryRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordVictoryRateUpdateProposalRequestAndWaitForReceiptAsync(CreateLordVictoryRateUpdateProposalFunction createLordVictoryRateUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordVictoryRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordVictoryRateUpdateProposalRequestAsync(BigInteger newVictoryRate)
        {
            var createLordVictoryRateUpdateProposalFunction = new CreateLordVictoryRateUpdateProposalFunction();
                createLordVictoryRateUpdateProposalFunction.NewVictoryRate = newVictoryRate;
            
             return ContractHandler.SendRequestAsync(createLordVictoryRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordVictoryRateUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newVictoryRate, CancellationTokenSource cancellationToken = null)
        {
            var createLordVictoryRateUpdateProposalFunction = new CreateLordVictoryRateUpdateProposalFunction();
                createLordVictoryRateUpdateProposalFunction.NewVictoryRate = newVictoryRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordVictoryRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordWarLordCasualtyRateUpdateProposalRequestAsync(CreateLordWarLordCasualtyRateUpdateProposalFunction createLordWarLordCasualtyRateUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createLordWarLordCasualtyRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordWarLordCasualtyRateUpdateProposalRequestAndWaitForReceiptAsync(CreateLordWarLordCasualtyRateUpdateProposalFunction createLordWarLordCasualtyRateUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordWarLordCasualtyRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateLordWarLordCasualtyRateUpdateProposalRequestAsync(BigInteger newWarCasualtyRate)
        {
            var createLordWarLordCasualtyRateUpdateProposalFunction = new CreateLordWarLordCasualtyRateUpdateProposalFunction();
                createLordWarLordCasualtyRateUpdateProposalFunction.NewWarCasualtyRate = newWarCasualtyRate;
            
             return ContractHandler.SendRequestAsync(createLordWarLordCasualtyRateUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateLordWarLordCasualtyRateUpdateProposalRequestAndWaitForReceiptAsync(BigInteger newWarCasualtyRate, CancellationTokenSource cancellationToken = null)
        {
            var createLordWarLordCasualtyRateUpdateProposalFunction = new CreateLordWarLordCasualtyRateUpdateProposalFunction();
                createLordWarLordCasualtyRateUpdateProposalFunction.NewWarCasualtyRate = newWarCasualtyRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createLordWarLordCasualtyRateUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateRoundSetPlayerRootAndNumberRequestAsync(CreateRoundSetPlayerRootAndNumberFunction createRoundSetPlayerRootAndNumberFunction)
        {
             return ContractHandler.SendRequestAsync(createRoundSetPlayerRootAndNumberFunction);
        }

        public Task<TransactionReceipt> CreateRoundSetPlayerRootAndNumberRequestAndWaitForReceiptAsync(CreateRoundSetPlayerRootAndNumberFunction createRoundSetPlayerRootAndNumberFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createRoundSetPlayerRootAndNumberFunction, cancellationToken);
        }

        public Task<string> CreateRoundSetPlayerRootAndNumberRequestAsync(BigInteger round, BigInteger level, byte[] root, BigInteger playerNumber)
        {
            var createRoundSetPlayerRootAndNumberFunction = new CreateRoundSetPlayerRootAndNumberFunction();
                createRoundSetPlayerRootAndNumberFunction.Round = round;
                createRoundSetPlayerRootAndNumberFunction.Level = level;
                createRoundSetPlayerRootAndNumberFunction.Root = root;
                createRoundSetPlayerRootAndNumberFunction.PlayerNumber = playerNumber;
            
             return ContractHandler.SendRequestAsync(createRoundSetPlayerRootAndNumberFunction);
        }

        public Task<TransactionReceipt> CreateRoundSetPlayerRootAndNumberRequestAndWaitForReceiptAsync(BigInteger round, BigInteger level, byte[] root, BigInteger playerNumber, CancellationTokenSource cancellationToken = null)
        {
            var createRoundSetPlayerRootAndNumberFunction = new CreateRoundSetPlayerRootAndNumberFunction();
                createRoundSetPlayerRootAndNumberFunction.Round = round;
                createRoundSetPlayerRootAndNumberFunction.Level = level;
                createRoundSetPlayerRootAndNumberFunction.Root = root;
                createRoundSetPlayerRootAndNumberFunction.PlayerNumber = playerNumber;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createRoundSetPlayerRootAndNumberFunction, cancellationToken);
        }

        public Task<string> CreateRoundUpdateLevelRewardRatesRequestAsync(CreateRoundUpdateLevelRewardRatesFunction createRoundUpdateLevelRewardRatesFunction)
        {
             return ContractHandler.SendRequestAsync(createRoundUpdateLevelRewardRatesFunction);
        }

        public Task<TransactionReceipt> CreateRoundUpdateLevelRewardRatesRequestAndWaitForReceiptAsync(CreateRoundUpdateLevelRewardRatesFunction createRoundUpdateLevelRewardRatesFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createRoundUpdateLevelRewardRatesFunction, cancellationToken);
        }

        public Task<string> CreateRoundUpdateLevelRewardRatesRequestAsync(List<BigInteger> newLevelWeights, BigInteger newTotalWeight)
        {
            var createRoundUpdateLevelRewardRatesFunction = new CreateRoundUpdateLevelRewardRatesFunction();
                createRoundUpdateLevelRewardRatesFunction.NewLevelWeights = newLevelWeights;
                createRoundUpdateLevelRewardRatesFunction.NewTotalWeight = newTotalWeight;
            
             return ContractHandler.SendRequestAsync(createRoundUpdateLevelRewardRatesFunction);
        }

        public Task<TransactionReceipt> CreateRoundUpdateLevelRewardRatesRequestAndWaitForReceiptAsync(List<BigInteger> newLevelWeights, BigInteger newTotalWeight, CancellationTokenSource cancellationToken = null)
        {
            var createRoundUpdateLevelRewardRatesFunction = new CreateRoundUpdateLevelRewardRatesFunction();
                createRoundUpdateLevelRewardRatesFunction.NewLevelWeights = newLevelWeights;
                createRoundUpdateLevelRewardRatesFunction.NewTotalWeight = newTotalWeight;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createRoundUpdateLevelRewardRatesFunction, cancellationToken);
        }

        public Task<string> CreateTokenCommunityMintRequestAsync(CreateTokenCommunityMintFunction createTokenCommunityMintFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenCommunityMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenCommunityMintRequestAndWaitForReceiptAsync(CreateTokenCommunityMintFunction createTokenCommunityMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenCommunityMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenCommunityMintRequestAsync(BigInteger amount)
        {
            var createTokenCommunityMintFunction = new CreateTokenCommunityMintFunction();
                createTokenCommunityMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(createTokenCommunityMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenCommunityMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var createTokenCommunityMintFunction = new CreateTokenCommunityMintFunction();
                createTokenCommunityMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenCommunityMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenDAOMintRequestAsync(CreateTokenDAOMintFunction createTokenDAOMintFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenDAOMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenDAOMintRequestAndWaitForReceiptAsync(CreateTokenDAOMintFunction createTokenDAOMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenDAOMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenDAOMintRequestAsync(BigInteger amount)
        {
            var createTokenDAOMintFunction = new CreateTokenDAOMintFunction();
                createTokenDAOMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(createTokenDAOMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenDAOMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var createTokenDAOMintFunction = new CreateTokenDAOMintFunction();
                createTokenDAOMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenDAOMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenDevelopmentMintRequestAsync(CreateTokenDevelopmentMintFunction createTokenDevelopmentMintFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenDevelopmentMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenDevelopmentMintRequestAndWaitForReceiptAsync(CreateTokenDevelopmentMintFunction createTokenDevelopmentMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenDevelopmentMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenDevelopmentMintRequestAsync(BigInteger amount)
        {
            var createTokenDevelopmentMintFunction = new CreateTokenDevelopmentMintFunction();
                createTokenDevelopmentMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(createTokenDevelopmentMintFunction);
        }

        public Task<TransactionReceipt> CreateTokenDevelopmentMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var createTokenDevelopmentMintFunction = new CreateTokenDevelopmentMintFunction();
                createTokenDevelopmentMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenDevelopmentMintFunction, cancellationToken);
        }

        public Task<string> CreateTokenMintPerSecondUpdateProposalRequestAsync(CreateTokenMintPerSecondUpdateProposalFunction createTokenMintPerSecondUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenMintPerSecondUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateTokenMintPerSecondUpdateProposalRequestAndWaitForReceiptAsync(CreateTokenMintPerSecondUpdateProposalFunction createTokenMintPerSecondUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenMintPerSecondUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateTokenMintPerSecondUpdateProposalRequestAsync(BigInteger mintIndex, BigInteger newMintPerSecond)
        {
            var createTokenMintPerSecondUpdateProposalFunction = new CreateTokenMintPerSecondUpdateProposalFunction();
                createTokenMintPerSecondUpdateProposalFunction.MintIndex = mintIndex;
                createTokenMintPerSecondUpdateProposalFunction.NewMintPerSecond = newMintPerSecond;
            
             return ContractHandler.SendRequestAsync(createTokenMintPerSecondUpdateProposalFunction);
        }

        public Task<TransactionReceipt> CreateTokenMintPerSecondUpdateProposalRequestAndWaitForReceiptAsync(BigInteger mintIndex, BigInteger newMintPerSecond, CancellationTokenSource cancellationToken = null)
        {
            var createTokenMintPerSecondUpdateProposalFunction = new CreateTokenMintPerSecondUpdateProposalFunction();
                createTokenMintPerSecondUpdateProposalFunction.MintIndex = mintIndex;
                createTokenMintPerSecondUpdateProposalFunction.NewMintPerSecond = newMintPerSecond;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenMintPerSecondUpdateProposalFunction, cancellationToken);
        }

        public Task<string> CreateTokenPauseRequestAsync(CreateTokenPauseFunction createTokenPauseFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenPauseFunction);
        }

        public Task<TransactionReceipt> CreateTokenPauseRequestAndWaitForReceiptAsync(CreateTokenPauseFunction createTokenPauseFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenPauseFunction, cancellationToken);
        }

        public Task<string> CreateTokenPauseRequestAsync(bool pauseToken)
        {
            var createTokenPauseFunction = new CreateTokenPauseFunction();
                createTokenPauseFunction.PauseToken = pauseToken;
            
             return ContractHandler.SendRequestAsync(createTokenPauseFunction);
        }

        public Task<TransactionReceipt> CreateTokenPauseRequestAndWaitForReceiptAsync(bool pauseToken, CancellationTokenSource cancellationToken = null)
        {
            var createTokenPauseFunction = new CreateTokenPauseFunction();
                createTokenPauseFunction.PauseToken = pauseToken;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenPauseFunction, cancellationToken);
        }

        public Task<string> CreateTokenSnapshotRequestAsync(CreateTokenSnapshotFunction createTokenSnapshotFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenSnapshotFunction);
        }

        public Task<string> CreateTokenSnapshotRequestAsync()
        {
             return ContractHandler.SendRequestAsync<CreateTokenSnapshotFunction>();
        }

        public Task<TransactionReceipt> CreateTokenSnapshotRequestAndWaitForReceiptAsync(CreateTokenSnapshotFunction createTokenSnapshotFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenSnapshotFunction, cancellationToken);
        }

        public Task<TransactionReceipt> CreateTokenSnapshotRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<CreateTokenSnapshotFunction>(null, cancellationToken);
        }

        public Task<string> CreateTokenStakingMintRequestAsync(CreateTokenStakingMintFunction createTokenStakingMintFunction)
        {
             return ContractHandler.SendRequestAsync(createTokenStakingMintFunction);
        }

        public Task<string> CreateTokenStakingMintRequestAsync()
        {
             return ContractHandler.SendRequestAsync<CreateTokenStakingMintFunction>();
        }

        public Task<TransactionReceipt> CreateTokenStakingMintRequestAndWaitForReceiptAsync(CreateTokenStakingMintFunction createTokenStakingMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createTokenStakingMintFunction, cancellationToken);
        }

        public Task<TransactionReceipt> CreateTokenStakingMintRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<CreateTokenStakingMintFunction>(null, cancellationToken);
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

        public Task<string> ExecuteRoleProposalRequestAsync(ExecuteRoleProposalFunction executeRoleProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeRoleProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteRoleProposalRequestAndWaitForReceiptAsync(ExecuteRoleProposalFunction executeRoleProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeRoleProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteRoleProposalRequestAsync(BigInteger proposalID)
        {
            var executeRoleProposalFunction = new ExecuteRoleProposalFunction();
                executeRoleProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeRoleProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteRoleProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeRoleProposalFunction = new ExecuteRoleProposalFunction();
                executeRoleProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeRoleProposalFunction, cancellationToken);
        }

        public Task<BigInteger> ExecutorProposalTypeIndexQueryAsync(ExecutorProposalTypeIndexFunction executorProposalTypeIndexFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ExecutorProposalTypeIndexFunction, BigInteger>(executorProposalTypeIndexFunction, blockParameter);
        }

        
        public Task<BigInteger> ExecutorProposalTypeIndexQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ExecutorProposalTypeIndexFunction, BigInteger>(null, blockParameter);
        }

        public Task<byte[]> GetRoleAdminQueryAsync(GetRoleAdminFunction getRoleAdminFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetRoleAdminFunction, byte[]>(getRoleAdminFunction, blockParameter);
        }

        
        public Task<byte[]> GetRoleAdminQueryAsync(byte[] role, BlockParameter blockParameter = null)
        {
            var getRoleAdminFunction = new GetRoleAdminFunction();
                getRoleAdminFunction.Role = role;
            
            return ContractHandler.QueryAsync<GetRoleAdminFunction, byte[]>(getRoleAdminFunction, blockParameter);
        }

        public Task<BigInteger> GetSignalTimingQueryAsync(GetSignalTimingFunction getSignalTimingFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetSignalTimingFunction, BigInteger>(getSignalTimingFunction, blockParameter);
        }

        
        public Task<BigInteger> GetSignalTimingQueryAsync(BigInteger signalIndex, BlockParameter blockParameter = null)
        {
            var getSignalTimingFunction = new GetSignalTimingFunction();
                getSignalTimingFunction.SignalIndex = signalIndex;
            
            return ContractHandler.QueryAsync<GetSignalTimingFunction, BigInteger>(getSignalTimingFunction, blockParameter);
        }

        public Task<string> GrantRoleRequestAsync(GrantRoleFunction grantRoleFunction)
        {
             return ContractHandler.SendRequestAsync(grantRoleFunction);
        }

        public Task<TransactionReceipt> GrantRoleRequestAndWaitForReceiptAsync(GrantRoleFunction grantRoleFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(grantRoleFunction, cancellationToken);
        }

        public Task<string> GrantRoleRequestAsync(byte[] role, string account)
        {
            var grantRoleFunction = new GrantRoleFunction();
                grantRoleFunction.Role = role;
                grantRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAsync(grantRoleFunction);
        }

        public Task<TransactionReceipt> GrantRoleRequestAndWaitForReceiptAsync(byte[] role, string account, CancellationTokenSource cancellationToken = null)
        {
            var grantRoleFunction = new GrantRoleFunction();
                grantRoleFunction.Role = role;
                grantRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(grantRoleFunction, cancellationToken);
        }

        public Task<bool> HasRoleQueryAsync(HasRoleFunction hasRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<HasRoleFunction, bool>(hasRoleFunction, blockParameter);
        }

        
        public Task<bool> HasRoleQueryAsync(byte[] role, string account, BlockParameter blockParameter = null)
        {
            var hasRoleFunction = new HasRoleFunction();
                hasRoleFunction.Role = role;
                hasRoleFunction.Account = account;
            
            return ContractHandler.QueryAsync<HasRoleFunction, bool>(hasRoleFunction, blockParameter);
        }

        public Task<bool> IsExecutorQueryAsync(IsExecutorFunction isExecutorFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsExecutorFunction, bool>(isExecutorFunction, blockParameter);
        }

        
        public Task<bool> IsExecutorQueryAsync(string returnValue1, BlockParameter blockParameter = null)
        {
            var isExecutorFunction = new IsExecutorFunction();
                isExecutorFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<IsExecutorFunction, bool>(isExecutorFunction, blockParameter);
        }

        public Task<BigInteger> NumOfExecutorsQueryAsync(NumOfExecutorsFunction numOfExecutorsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NumOfExecutorsFunction, BigInteger>(numOfExecutorsFunction, blockParameter);
        }

        
        public Task<BigInteger> NumOfExecutorsQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NumOfExecutorsFunction, BigInteger>(null, blockParameter);
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

        public Task<string> ProposeExecutorRoleRequestAsync(ProposeExecutorRoleFunction proposeExecutorRoleFunction)
        {
             return ContractHandler.SendRequestAsync(proposeExecutorRoleFunction);
        }

        public Task<TransactionReceipt> ProposeExecutorRoleRequestAndWaitForReceiptAsync(ProposeExecutorRoleFunction proposeExecutorRoleFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeExecutorRoleFunction, cancellationToken);
        }

        public Task<string> ProposeExecutorRoleRequestAsync(string address, bool isAssigning)
        {
            var proposeExecutorRoleFunction = new ProposeExecutorRoleFunction();
                proposeExecutorRoleFunction.Address = address;
                proposeExecutorRoleFunction.IsAssigning = isAssigning;
            
             return ContractHandler.SendRequestAsync(proposeExecutorRoleFunction);
        }

        public Task<TransactionReceipt> ProposeExecutorRoleRequestAndWaitForReceiptAsync(string address, bool isAssigning, CancellationTokenSource cancellationToken = null)
        {
            var proposeExecutorRoleFunction = new ProposeExecutorRoleFunction();
                proposeExecutorRoleFunction.Address = address;
                proposeExecutorRoleFunction.IsAssigning = isAssigning;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeExecutorRoleFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(ProposeFunctionsProposalTypesUpdateFunction proposeFunctionsProposalTypesUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeFunctionsProposalTypesUpdateRequestAsync(BigInteger newIndex)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAsync(proposeFunctionsProposalTypesUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeFunctionsProposalTypesUpdateRequestAndWaitForReceiptAsync(BigInteger newIndex, CancellationTokenSource cancellationToken = null)
        {
            var proposeFunctionsProposalTypesUpdateFunction = new ProposeFunctionsProposalTypesUpdateFunction();
                proposeFunctionsProposalTypesUpdateFunction.NewIndex = newIndex;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeFunctionsProposalTypesUpdateFunction, cancellationToken);
        }

        public Task<string> RenounceRoleRequestAsync(RenounceRoleFunction renounceRoleFunction)
        {
             return ContractHandler.SendRequestAsync(renounceRoleFunction);
        }

        public Task<TransactionReceipt> RenounceRoleRequestAndWaitForReceiptAsync(RenounceRoleFunction renounceRoleFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(renounceRoleFunction, cancellationToken);
        }

        public Task<string> RenounceRoleRequestAsync(byte[] role, string account)
        {
            var renounceRoleFunction = new RenounceRoleFunction();
                renounceRoleFunction.Role = role;
                renounceRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAsync(renounceRoleFunction);
        }

        public Task<TransactionReceipt> RenounceRoleRequestAndWaitForReceiptAsync(byte[] role, string account, CancellationTokenSource cancellationToken = null)
        {
            var renounceRoleFunction = new RenounceRoleFunction();
                renounceRoleFunction.Role = role;
                renounceRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(renounceRoleFunction, cancellationToken);
        }

        public Task<string> RevokeRoleRequestAsync(RevokeRoleFunction revokeRoleFunction)
        {
             return ContractHandler.SendRequestAsync(revokeRoleFunction);
        }

        public Task<TransactionReceipt> RevokeRoleRequestAndWaitForReceiptAsync(RevokeRoleFunction revokeRoleFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revokeRoleFunction, cancellationToken);
        }

        public Task<string> RevokeRoleRequestAsync(byte[] role, string account)
        {
            var revokeRoleFunction = new RevokeRoleFunction();
                revokeRoleFunction.Role = role;
                revokeRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAsync(revokeRoleFunction);
        }

        public Task<TransactionReceipt> RevokeRoleRequestAndWaitForReceiptAsync(byte[] role, string account, CancellationTokenSource cancellationToken = null)
        {
            var revokeRoleFunction = new RevokeRoleFunction();
                revokeRoleFunction.Role = role;
                revokeRoleFunction.Account = account;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(revokeRoleFunction, cancellationToken);
        }

        public Task<BigInteger> SignalTimeQueryAsync(SignalTimeFunction signalTimeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SignalTimeFunction, BigInteger>(signalTimeFunction, blockParameter);
        }

        
        public Task<BigInteger> SignalTimeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SignalTimeFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> SignalTrackerIDQueryAsync(SignalTrackerIDFunction signalTrackerIDFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SignalTrackerIDFunction, BigInteger>(signalTrackerIDFunction, blockParameter);
        }

        
        public Task<BigInteger> SignalTrackerIDQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var signalTrackerIDFunction = new SignalTrackerIDFunction();
                signalTrackerIDFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<SignalTrackerIDFunction, BigInteger>(signalTrackerIDFunction, blockParameter);
        }

        public Task<SignalsOutputDTO> SignalsQueryAsync(SignalsFunction signalsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<SignalsFunction, SignalsOutputDTO>(signalsFunction, blockParameter);
        }

        public Task<SignalsOutputDTO> SignalsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var signalsFunction = new SignalsFunction();
                signalsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<SignalsFunction, SignalsOutputDTO>(signalsFunction, blockParameter);
        }

        public Task<bool> SupportsInterfaceQueryAsync(SupportsInterfaceFunction supportsInterfaceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        
        public Task<bool> SupportsInterfaceQueryAsync(byte[] interfaceId, BlockParameter blockParameter = null)
        {
            var supportsInterfaceFunction = new SupportsInterfaceFunction();
                supportsInterfaceFunction.InterfaceId = interfaceId;
            
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        public Task<string> UpdateContractAddressRequestAsync(UpdateContractAddressFunction updateContractAddressFunction)
        {
             return ContractHandler.SendRequestAsync(updateContractAddressFunction);
        }

        public Task<TransactionReceipt> UpdateContractAddressRequestAndWaitForReceiptAsync(UpdateContractAddressFunction updateContractAddressFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateContractAddressFunction, cancellationToken);
        }

        public Task<string> UpdateContractAddressRequestAsync(BigInteger contractIndex, string newAddress)
        {
            var updateContractAddressFunction = new UpdateContractAddressFunction();
                updateContractAddressFunction.ContractIndex = contractIndex;
                updateContractAddressFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAsync(updateContractAddressFunction);
        }

        public Task<TransactionReceipt> UpdateContractAddressRequestAndWaitForReceiptAsync(BigInteger contractIndex, string newAddress, CancellationTokenSource cancellationToken = null)
        {
            var updateContractAddressFunction = new UpdateContractAddressFunction();
                updateContractAddressFunction.ContractIndex = contractIndex;
                updateContractAddressFunction.NewAddress = newAddress;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateContractAddressFunction, cancellationToken);
        }
    }
}
