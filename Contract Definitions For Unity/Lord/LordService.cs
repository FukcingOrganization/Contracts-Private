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
using Contracts.Contracts.Lord.ContractDefinition;

namespace Contracts.Contracts.Lord
{
    public partial class LordService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, LordDeployment lordDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<LordDeployment>().SendRequestAndWaitForReceiptAsync(lordDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, LordDeployment lordDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<LordDeployment>().SendRequestAsync(lordDeployment);
        }

        public static async Task<LordService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, LordDeployment lordDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, lordDeployment, cancellationTokenSource);
            return new LordService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public LordService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }

        public Task<string> DAOvoteRequestAsync(DAOvoteFunction dAOvoteFunction)
        {
             return ContractHandler.SendRequestAsync(dAOvoteFunction);
        }

        public Task<TransactionReceipt> DAOvoteRequestAndWaitForReceiptAsync(DAOvoteFunction dAOvoteFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dAOvoteFunction, cancellationToken);
        }

        public Task<string> DAOvoteRequestAsync(BigInteger proposalID, bool isApproving, BigInteger lordID)
        {
            var dAOvoteFunction = new DAOvoteFunction();
                dAOvoteFunction.ProposalID = proposalID;
                dAOvoteFunction.IsApproving = isApproving;
                dAOvoteFunction.LordID = lordID;
            
             return ContractHandler.SendRequestAsync(dAOvoteFunction);
        }

        public Task<TransactionReceipt> DAOvoteRequestAndWaitForReceiptAsync(BigInteger proposalID, bool isApproving, BigInteger lordID, CancellationTokenSource cancellationToken = null)
        {
            var dAOvoteFunction = new DAOvoteFunction();
                dAOvoteFunction.ProposalID = proposalID;
                dAOvoteFunction.IsApproving = isApproving;
                dAOvoteFunction.LordID = lordID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dAOvoteFunction, cancellationToken);
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

        public Task<string> ApproveRequestAsync(ApproveFunction approveFunction)
        {
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(ApproveFunction approveFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<string> ApproveRequestAsync(string to, BigInteger tokenId)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.To = to;
                approveFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.To = to;
                approveFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<BigInteger> BalanceOfQueryAsync(BalanceOfFunction balanceOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        
        public Task<BigInteger> BalanceOfQueryAsync(string owner, BlockParameter blockParameter = null)
        {
            var balanceOfFunction = new BalanceOfFunction();
                balanceOfFunction.Owner = owner;
            
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        public Task<BigInteger> BaseMintCostQueryAsync(BaseMintCostFunction baseMintCostFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BaseMintCostFunction, BigInteger>(baseMintCostFunction, blockParameter);
        }

        
        public Task<BigInteger> BaseMintCostQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BaseMintCostFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> BaseTaxRateQueryAsync(BaseTaxRateFunction baseTaxRateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BaseTaxRateFunction, BigInteger>(baseTaxRateFunction, blockParameter);
        }

        
        public Task<BigInteger> BaseTaxRateQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BaseTaxRateFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> BurnRequestAsync(BurnFunction burnFunction)
        {
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BurnFunction burnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnRequestAsync(BigInteger tokenId)
        {
            var burnFunction = new BurnFunction();
                burnFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var burnFunction = new BurnFunction();
                burnFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> ClaimRebellionRewardsRequestAsync(ClaimRebellionRewardsFunction claimRebellionRewardsFunction)
        {
             return ContractHandler.SendRequestAsync(claimRebellionRewardsFunction);
        }

        public Task<TransactionReceipt> ClaimRebellionRewardsRequestAndWaitForReceiptAsync(ClaimRebellionRewardsFunction claimRebellionRewardsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRebellionRewardsFunction, cancellationToken);
        }

        public Task<string> ClaimRebellionRewardsRequestAsync(BigInteger rebellionID, BigInteger lordID)
        {
            var claimRebellionRewardsFunction = new ClaimRebellionRewardsFunction();
                claimRebellionRewardsFunction.RebellionID = rebellionID;
                claimRebellionRewardsFunction.LordID = lordID;
            
             return ContractHandler.SendRequestAsync(claimRebellionRewardsFunction);
        }

        public Task<TransactionReceipt> ClaimRebellionRewardsRequestAndWaitForReceiptAsync(BigInteger rebellionID, BigInteger lordID, CancellationTokenSource cancellationToken = null)
        {
            var claimRebellionRewardsFunction = new ClaimRebellionRewardsFunction();
                claimRebellionRewardsFunction.RebellionID = rebellionID;
                claimRebellionRewardsFunction.LordID = lordID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRebellionRewardsFunction, cancellationToken);
        }

        public Task<string> ClanRegistrationRequestAsync(ClanRegistrationFunction clanRegistrationFunction)
        {
             return ContractHandler.SendRequestAsync(clanRegistrationFunction);
        }

        public Task<TransactionReceipt> ClanRegistrationRequestAndWaitForReceiptAsync(ClanRegistrationFunction clanRegistrationFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(clanRegistrationFunction, cancellationToken);
        }

        public Task<string> ClanRegistrationRequestAsync(BigInteger lordID, BigInteger clanID)
        {
            var clanRegistrationFunction = new ClanRegistrationFunction();
                clanRegistrationFunction.LordID = lordID;
                clanRegistrationFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAsync(clanRegistrationFunction);
        }

        public Task<TransactionReceipt> ClanRegistrationRequestAndWaitForReceiptAsync(BigInteger lordID, BigInteger clanID, CancellationTokenSource cancellationToken = null)
        {
            var clanRegistrationFunction = new ClanRegistrationFunction();
                clanRegistrationFunction.LordID = lordID;
                clanRegistrationFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(clanRegistrationFunction, cancellationToken);
        }

        public Task<BigInteger> ClansOfQueryAsync(ClansOfFunction clansOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClansOfFunction, BigInteger>(clansOfFunction, blockParameter);
        }

        
        public Task<BigInteger> ClansOfQueryAsync(BigInteger returnValue1, BigInteger returnValue2, BlockParameter blockParameter = null)
        {
            var clansOfFunction = new ClansOfFunction();
                clansOfFunction.ReturnValue1 = returnValue1;
                clansOfFunction.ReturnValue2 = returnValue2;
            
            return ContractHandler.QueryAsync<ClansOfFunction, BigInteger>(clansOfFunction, blockParameter);
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

        public Task<string> ExecuteBaseTaxRateProposalRequestAsync(ExecuteBaseTaxRateProposalFunction executeBaseTaxRateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeBaseTaxRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteBaseTaxRateProposalRequestAndWaitForReceiptAsync(ExecuteBaseTaxRateProposalFunction executeBaseTaxRateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeBaseTaxRateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteBaseTaxRateProposalRequestAsync(BigInteger proposalID)
        {
            var executeBaseTaxRateProposalFunction = new ExecuteBaseTaxRateProposalFunction();
                executeBaseTaxRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeBaseTaxRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteBaseTaxRateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeBaseTaxRateProposalFunction = new ExecuteBaseTaxRateProposalFunction();
                executeBaseTaxRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeBaseTaxRateProposalFunction, cancellationToken);
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

        public Task<string> ExecuteRebellionLengthProposalRequestAsync(ExecuteRebellionLengthProposalFunction executeRebellionLengthProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeRebellionLengthProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteRebellionLengthProposalRequestAndWaitForReceiptAsync(ExecuteRebellionLengthProposalFunction executeRebellionLengthProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeRebellionLengthProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteRebellionLengthProposalRequestAsync(BigInteger proposalID)
        {
            var executeRebellionLengthProposalFunction = new ExecuteRebellionLengthProposalFunction();
                executeRebellionLengthProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeRebellionLengthProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteRebellionLengthProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeRebellionLengthProposalFunction = new ExecuteRebellionLengthProposalFunction();
                executeRebellionLengthProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeRebellionLengthProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteSignalLengthProposalRequestAsync(ExecuteSignalLengthProposalFunction executeSignalLengthProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeSignalLengthProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteSignalLengthProposalRequestAndWaitForReceiptAsync(ExecuteSignalLengthProposalFunction executeSignalLengthProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeSignalLengthProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteSignalLengthProposalRequestAsync(BigInteger proposalID)
        {
            var executeSignalLengthProposalFunction = new ExecuteSignalLengthProposalFunction();
                executeSignalLengthProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeSignalLengthProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteSignalLengthProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeSignalLengthProposalFunction = new ExecuteSignalLengthProposalFunction();
                executeSignalLengthProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeSignalLengthProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteTaxRateChangeProposalRequestAsync(ExecuteTaxRateChangeProposalFunction executeTaxRateChangeProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeTaxRateChangeProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteTaxRateChangeProposalRequestAndWaitForReceiptAsync(ExecuteTaxRateChangeProposalFunction executeTaxRateChangeProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeTaxRateChangeProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteTaxRateChangeProposalRequestAsync(BigInteger proposalID)
        {
            var executeTaxRateChangeProposalFunction = new ExecuteTaxRateChangeProposalFunction();
                executeTaxRateChangeProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeTaxRateChangeProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteTaxRateChangeProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeTaxRateChangeProposalFunction = new ExecuteTaxRateChangeProposalFunction();
                executeTaxRateChangeProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeTaxRateChangeProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteVictoryRateProposalRequestAsync(ExecuteVictoryRateProposalFunction executeVictoryRateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeVictoryRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteVictoryRateProposalRequestAndWaitForReceiptAsync(ExecuteVictoryRateProposalFunction executeVictoryRateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeVictoryRateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteVictoryRateProposalRequestAsync(BigInteger proposalID)
        {
            var executeVictoryRateProposalFunction = new ExecuteVictoryRateProposalFunction();
                executeVictoryRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeVictoryRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteVictoryRateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeVictoryRateProposalFunction = new ExecuteVictoryRateProposalFunction();
                executeVictoryRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeVictoryRateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteWarCasualtyRateProposalRequestAsync(ExecuteWarCasualtyRateProposalFunction executeWarCasualtyRateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeWarCasualtyRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteWarCasualtyRateProposalRequestAndWaitForReceiptAsync(ExecuteWarCasualtyRateProposalFunction executeWarCasualtyRateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeWarCasualtyRateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteWarCasualtyRateProposalRequestAsync(BigInteger proposalID)
        {
            var executeWarCasualtyRateProposalFunction = new ExecuteWarCasualtyRateProposalFunction();
                executeWarCasualtyRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeWarCasualtyRateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteWarCasualtyRateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeWarCasualtyRateProposalFunction = new ExecuteWarCasualtyRateProposalFunction();
                executeWarCasualtyRateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeWarCasualtyRateProposalFunction, cancellationToken);
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

        public Task<string> FundLordRequestAsync(FundLordFunction fundLordFunction)
        {
             return ContractHandler.SendRequestAsync(fundLordFunction);
        }

        public Task<TransactionReceipt> FundLordRequestAndWaitForReceiptAsync(FundLordFunction fundLordFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundLordFunction, cancellationToken);
        }

        public Task<string> FundLordRequestAsync(BigInteger lordID, BigInteger amount)
        {
            var fundLordFunction = new FundLordFunction();
                fundLordFunction.LordID = lordID;
                fundLordFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(fundLordFunction);
        }

        public Task<TransactionReceipt> FundLordRequestAndWaitForReceiptAsync(BigInteger lordID, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var fundLordFunction = new FundLordFunction();
                fundLordFunction.LordID = lordID;
                fundLordFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundLordFunction, cancellationToken);
        }

        public Task<string> FundRebelsRequestAsync(FundRebelsFunction fundRebelsFunction)
        {
             return ContractHandler.SendRequestAsync(fundRebelsFunction);
        }

        public Task<TransactionReceipt> FundRebelsRequestAndWaitForReceiptAsync(FundRebelsFunction fundRebelsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundRebelsFunction, cancellationToken);
        }

        public Task<string> FundRebelsRequestAsync(BigInteger lordID, BigInteger amount)
        {
            var fundRebelsFunction = new FundRebelsFunction();
                fundRebelsFunction.LordID = lordID;
                fundRebelsFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(fundRebelsFunction);
        }

        public Task<TransactionReceipt> FundRebelsRequestAndWaitForReceiptAsync(BigInteger lordID, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var fundRebelsFunction = new FundRebelsFunction();
                fundRebelsFunction.LordID = lordID;
                fundRebelsFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(fundRebelsFunction, cancellationToken);
        }

        public Task<string> GetApprovedQueryAsync(GetApprovedFunction getApprovedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetApprovedFunction, string>(getApprovedFunction, blockParameter);
        }

        
        public Task<string> GetApprovedQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var getApprovedFunction = new GetApprovedFunction();
                getApprovedFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<GetApprovedFunction, string>(getApprovedFunction, blockParameter);
        }

        public Task<bool> IsApprovedForAllQueryAsync(IsApprovedForAllFunction isApprovedForAllFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        
        public Task<bool> IsApprovedForAllQueryAsync(string owner, string @operator, BlockParameter blockParameter = null)
        {
            var isApprovedForAllFunction = new IsApprovedForAllFunction();
                isApprovedForAllFunction.Owner = owner;
                isApprovedForAllFunction.Operator = @operator;
            
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        public Task<bool> IsClanSignalledQueryAsync(IsClanSignalledFunction isClanSignalledFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsClanSignalledFunction, bool>(isClanSignalledFunction, blockParameter);
        }

        
        public Task<bool> IsClanSignalledQueryAsync(BigInteger rebellionNumber, BigInteger clanID, BlockParameter blockParameter = null)
        {
            var isClanSignalledFunction = new IsClanSignalledFunction();
                isClanSignalledFunction.RebellionNumber = rebellionNumber;
                isClanSignalledFunction.ClanID = clanID;
            
            return ContractHandler.QueryAsync<IsClanSignalledFunction, bool>(isClanSignalledFunction, blockParameter);
        }

        public Task<bool> IsRentedQueryAsync(IsRentedFunction isRentedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsRentedFunction, bool>(isRentedFunction, blockParameter);
        }

        
        public Task<bool> IsRentedQueryAsync(BigInteger lordID, BlockParameter blockParameter = null)
        {
            var isRentedFunction = new IsRentedFunction();
                isRentedFunction.LordID = lordID;
            
            return ContractHandler.QueryAsync<IsRentedFunction, bool>(isRentedFunction, blockParameter);
        }

        public Task<string> LordMintRequestAsync(LordMintFunction lordMintFunction)
        {
             return ContractHandler.SendRequestAsync(lordMintFunction);
        }

        public Task<string> LordMintRequestAsync()
        {
             return ContractHandler.SendRequestAsync<LordMintFunction>();
        }

        public Task<TransactionReceipt> LordMintRequestAndWaitForReceiptAsync(LordMintFunction lordMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(lordMintFunction, cancellationToken);
        }

        public Task<TransactionReceipt> LordMintRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<LordMintFunction>(null, cancellationToken);
        }

        public Task<LordTaxInfoOutputDTO> LordTaxInfoQueryAsync(LordTaxInfoFunction lordTaxInfoFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<LordTaxInfoFunction, LordTaxInfoOutputDTO>(lordTaxInfoFunction, blockParameter);
        }

        public Task<LordTaxInfoOutputDTO> LordTaxInfoQueryAsync(BigInteger lordID, BlockParameter blockParameter = null)
        {
            var lordTaxInfoFunction = new LordTaxInfoFunction();
                lordTaxInfoFunction.LordID = lordID;
            
            return ContractHandler.QueryDeserializingToObjectAsync<LordTaxInfoFunction, LordTaxInfoOutputDTO>(lordTaxInfoFunction, blockParameter);
        }

        public Task<BigInteger> MaxSupplyQueryAsync(MaxSupplyFunction maxSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MaxSupplyFunction, BigInteger>(maxSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> MaxSupplyQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MaxSupplyFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> MintClanLicenseRequestAsync(MintClanLicenseFunction mintClanLicenseFunction)
        {
             return ContractHandler.SendRequestAsync(mintClanLicenseFunction);
        }

        public Task<TransactionReceipt> MintClanLicenseRequestAndWaitForReceiptAsync(MintClanLicenseFunction mintClanLicenseFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintClanLicenseFunction, cancellationToken);
        }

        public Task<string> MintClanLicenseRequestAsync(BigInteger lordID, BigInteger amount, byte[] data)
        {
            var mintClanLicenseFunction = new MintClanLicenseFunction();
                mintClanLicenseFunction.LordID = lordID;
                mintClanLicenseFunction.Amount = amount;
                mintClanLicenseFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(mintClanLicenseFunction);
        }

        public Task<TransactionReceipt> MintClanLicenseRequestAndWaitForReceiptAsync(BigInteger lordID, BigInteger amount, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var mintClanLicenseFunction = new MintClanLicenseFunction();
                mintClanLicenseFunction.LordID = lordID;
                mintClanLicenseFunction.Amount = amount;
                mintClanLicenseFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintClanLicenseFunction, cancellationToken);
        }

        public Task<BigInteger> MintCostIncrementQueryAsync(MintCostIncrementFunction mintCostIncrementFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MintCostIncrementFunction, BigInteger>(mintCostIncrementFunction, blockParameter);
        }

        
        public Task<BigInteger> MintCostIncrementQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MintCostIncrementFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> NameQueryAsync(NameFunction nameFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(nameFunction, blockParameter);
        }

        
        public Task<string> NameQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> NumberOfClansQueryAsync(NumberOfClansFunction numberOfClansFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NumberOfClansFunction, BigInteger>(numberOfClansFunction, blockParameter);
        }

        
        public Task<BigInteger> NumberOfClansQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var numberOfClansFunction = new NumberOfClansFunction();
                numberOfClansFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<NumberOfClansFunction, BigInteger>(numberOfClansFunction, blockParameter);
        }

        public Task<BigInteger> NumberOfGloriesQueryAsync(NumberOfGloriesFunction numberOfGloriesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NumberOfGloriesFunction, BigInteger>(numberOfGloriesFunction, blockParameter);
        }

        
        public Task<BigInteger> NumberOfGloriesQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var numberOfGloriesFunction = new NumberOfGloriesFunction();
                numberOfGloriesFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<NumberOfGloriesFunction, BigInteger>(numberOfGloriesFunction, blockParameter);
        }

        public Task<string> OwnerOfQueryAsync(OwnerOfFunction ownerOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerOfFunction, string>(ownerOfFunction, blockParameter);
        }

        
        public Task<string> OwnerOfQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var ownerOfFunction = new OwnerOfFunction();
                ownerOfFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<OwnerOfFunction, string>(ownerOfFunction, blockParameter);
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

        public Task<string> ProposeBaseTaxRateUpdateRequestAsync(ProposeBaseTaxRateUpdateFunction proposeBaseTaxRateUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeBaseTaxRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeBaseTaxRateUpdateRequestAndWaitForReceiptAsync(ProposeBaseTaxRateUpdateFunction proposeBaseTaxRateUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeBaseTaxRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeBaseTaxRateUpdateRequestAsync(BigInteger newBaseTaxRate)
        {
            var proposeBaseTaxRateUpdateFunction = new ProposeBaseTaxRateUpdateFunction();
                proposeBaseTaxRateUpdateFunction.NewBaseTaxRate = newBaseTaxRate;
            
             return ContractHandler.SendRequestAsync(proposeBaseTaxRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeBaseTaxRateUpdateRequestAndWaitForReceiptAsync(BigInteger newBaseTaxRate, CancellationTokenSource cancellationToken = null)
        {
            var proposeBaseTaxRateUpdateFunction = new ProposeBaseTaxRateUpdateFunction();
                proposeBaseTaxRateUpdateFunction.NewBaseTaxRate = newBaseTaxRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeBaseTaxRateUpdateFunction, cancellationToken);
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

        public Task<string> ProposeRebellionLengthUpdateRequestAsync(ProposeRebellionLengthUpdateFunction proposeRebellionLengthUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeRebellionLengthUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeRebellionLengthUpdateRequestAndWaitForReceiptAsync(ProposeRebellionLengthUpdateFunction proposeRebellionLengthUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeRebellionLengthUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeRebellionLengthUpdateRequestAsync(BigInteger newRebellionLength)
        {
            var proposeRebellionLengthUpdateFunction = new ProposeRebellionLengthUpdateFunction();
                proposeRebellionLengthUpdateFunction.NewRebellionLength = newRebellionLength;
            
             return ContractHandler.SendRequestAsync(proposeRebellionLengthUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeRebellionLengthUpdateRequestAndWaitForReceiptAsync(BigInteger newRebellionLength, CancellationTokenSource cancellationToken = null)
        {
            var proposeRebellionLengthUpdateFunction = new ProposeRebellionLengthUpdateFunction();
                proposeRebellionLengthUpdateFunction.NewRebellionLength = newRebellionLength;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeRebellionLengthUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeSignalLengthUpdateRequestAsync(ProposeSignalLengthUpdateFunction proposeSignalLengthUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeSignalLengthUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeSignalLengthUpdateRequestAndWaitForReceiptAsync(ProposeSignalLengthUpdateFunction proposeSignalLengthUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeSignalLengthUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeSignalLengthUpdateRequestAsync(BigInteger newSignalLength)
        {
            var proposeSignalLengthUpdateFunction = new ProposeSignalLengthUpdateFunction();
                proposeSignalLengthUpdateFunction.NewSignalLength = newSignalLength;
            
             return ContractHandler.SendRequestAsync(proposeSignalLengthUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeSignalLengthUpdateRequestAndWaitForReceiptAsync(BigInteger newSignalLength, CancellationTokenSource cancellationToken = null)
        {
            var proposeSignalLengthUpdateFunction = new ProposeSignalLengthUpdateFunction();
                proposeSignalLengthUpdateFunction.NewSignalLength = newSignalLength;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeSignalLengthUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeTaxChangeRateUpdateRequestAsync(ProposeTaxChangeRateUpdateFunction proposeTaxChangeRateUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeTaxChangeRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeTaxChangeRateUpdateRequestAndWaitForReceiptAsync(ProposeTaxChangeRateUpdateFunction proposeTaxChangeRateUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeTaxChangeRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeTaxChangeRateUpdateRequestAsync(BigInteger newTaxChangeRate)
        {
            var proposeTaxChangeRateUpdateFunction = new ProposeTaxChangeRateUpdateFunction();
                proposeTaxChangeRateUpdateFunction.NewTaxChangeRate = newTaxChangeRate;
            
             return ContractHandler.SendRequestAsync(proposeTaxChangeRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeTaxChangeRateUpdateRequestAndWaitForReceiptAsync(BigInteger newTaxChangeRate, CancellationTokenSource cancellationToken = null)
        {
            var proposeTaxChangeRateUpdateFunction = new ProposeTaxChangeRateUpdateFunction();
                proposeTaxChangeRateUpdateFunction.NewTaxChangeRate = newTaxChangeRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeTaxChangeRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeVictoryRateUpdateRequestAsync(ProposeVictoryRateUpdateFunction proposeVictoryRateUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeVictoryRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeVictoryRateUpdateRequestAndWaitForReceiptAsync(ProposeVictoryRateUpdateFunction proposeVictoryRateUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeVictoryRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeVictoryRateUpdateRequestAsync(BigInteger newVictoryRate)
        {
            var proposeVictoryRateUpdateFunction = new ProposeVictoryRateUpdateFunction();
                proposeVictoryRateUpdateFunction.NewVictoryRate = newVictoryRate;
            
             return ContractHandler.SendRequestAsync(proposeVictoryRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeVictoryRateUpdateRequestAndWaitForReceiptAsync(BigInteger newVictoryRate, CancellationTokenSource cancellationToken = null)
        {
            var proposeVictoryRateUpdateFunction = new ProposeVictoryRateUpdateFunction();
                proposeVictoryRateUpdateFunction.NewVictoryRate = newVictoryRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeVictoryRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeWarCasualtyRateUpdateRequestAsync(ProposeWarCasualtyRateUpdateFunction proposeWarCasualtyRateUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeWarCasualtyRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeWarCasualtyRateUpdateRequestAndWaitForReceiptAsync(ProposeWarCasualtyRateUpdateFunction proposeWarCasualtyRateUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeWarCasualtyRateUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeWarCasualtyRateUpdateRequestAsync(BigInteger newWarCasualtyRate)
        {
            var proposeWarCasualtyRateUpdateFunction = new ProposeWarCasualtyRateUpdateFunction();
                proposeWarCasualtyRateUpdateFunction.NewWarCasualtyRate = newWarCasualtyRate;
            
             return ContractHandler.SendRequestAsync(proposeWarCasualtyRateUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeWarCasualtyRateUpdateRequestAndWaitForReceiptAsync(BigInteger newWarCasualtyRate, CancellationTokenSource cancellationToken = null)
        {
            var proposeWarCasualtyRateUpdateFunction = new ProposeWarCasualtyRateUpdateFunction();
                proposeWarCasualtyRateUpdateFunction.NewWarCasualtyRate = newWarCasualtyRate;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeWarCasualtyRateUpdateFunction, cancellationToken);
        }

        public Task<BigInteger> RebellionLengthQueryAsync(RebellionLengthFunction rebellionLengthFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RebellionLengthFunction, BigInteger>(rebellionLengthFunction, blockParameter);
        }

        
        public Task<BigInteger> RebellionLengthQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RebellionLengthFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> RebellionOfQueryAsync(RebellionOfFunction rebellionOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RebellionOfFunction, BigInteger>(rebellionOfFunction, blockParameter);
        }

        
        public Task<BigInteger> RebellionOfQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var rebellionOfFunction = new RebellionOfFunction();
                rebellionOfFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<RebellionOfFunction, BigInteger>(rebellionOfFunction, blockParameter);
        }

        public Task<RebellionsOutputDTO> RebellionsQueryAsync(RebellionsFunction rebellionsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<RebellionsFunction, RebellionsOutputDTO>(rebellionsFunction, blockParameter);
        }

        public Task<RebellionsOutputDTO> RebellionsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var rebellionsFunction = new RebellionsFunction();
                rebellionsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<RebellionsFunction, RebellionsOutputDTO>(rebellionsFunction, blockParameter);
        }

        public Task<string> SafeTransferFromRequestAsync(SafeTransferFromFunction safeTransferFromFunction)
        {
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(SafeTransferFromFunction safeTransferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(string from, string to, BigInteger tokenId)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(SafeTransferFrom1Function safeTransferFrom1Function)
        {
             return ContractHandler.SendRequestAsync(safeTransferFrom1Function);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(SafeTransferFrom1Function safeTransferFrom1Function, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFrom1Function, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(string from, string to, BigInteger tokenId, byte[] data)
        {
            var safeTransferFrom1Function = new SafeTransferFrom1Function();
                safeTransferFrom1Function.From = from;
                safeTransferFrom1Function.To = to;
                safeTransferFrom1Function.TokenId = tokenId;
                safeTransferFrom1Function.Data = data;
            
             return ContractHandler.SendRequestAsync(safeTransferFrom1Function);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var safeTransferFrom1Function = new SafeTransferFrom1Function();
                safeTransferFrom1Function.From = from;
                safeTransferFrom1Function.To = to;
                safeTransferFrom1Function.TokenId = tokenId;
                safeTransferFrom1Function.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFrom1Function, cancellationToken);
        }

        public Task<string> SetApprovalForAllRequestAsync(SetApprovalForAllFunction setApprovalForAllFunction)
        {
             return ContractHandler.SendRequestAsync(setApprovalForAllFunction);
        }

        public Task<TransactionReceipt> SetApprovalForAllRequestAndWaitForReceiptAsync(SetApprovalForAllFunction setApprovalForAllFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setApprovalForAllFunction, cancellationToken);
        }

        public Task<string> SetApprovalForAllRequestAsync(string @operator, bool approved)
        {
            var setApprovalForAllFunction = new SetApprovalForAllFunction();
                setApprovalForAllFunction.Operator = @operator;
                setApprovalForAllFunction.Approved = approved;
            
             return ContractHandler.SendRequestAsync(setApprovalForAllFunction);
        }

        public Task<TransactionReceipt> SetApprovalForAllRequestAndWaitForReceiptAsync(string @operator, bool approved, CancellationTokenSource cancellationToken = null)
        {
            var setApprovalForAllFunction = new SetApprovalForAllFunction();
                setApprovalForAllFunction.Operator = @operator;
                setApprovalForAllFunction.Approved = approved;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setApprovalForAllFunction, cancellationToken);
        }

        public Task<string> SetBaseURIRequestAsync(SetBaseURIFunction setBaseURIFunction)
        {
             return ContractHandler.SendRequestAsync(setBaseURIFunction);
        }

        public Task<TransactionReceipt> SetBaseURIRequestAndWaitForReceiptAsync(SetBaseURIFunction setBaseURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setBaseURIFunction, cancellationToken);
        }

        public Task<string> SetBaseURIRequestAsync(string newURI)
        {
            var setBaseURIFunction = new SetBaseURIFunction();
                setBaseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAsync(setBaseURIFunction);
        }

        public Task<TransactionReceipt> SetBaseURIRequestAndWaitForReceiptAsync(string newURI, CancellationTokenSource cancellationToken = null)
        {
            var setBaseURIFunction = new SetBaseURIFunction();
                setBaseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setBaseURIFunction, cancellationToken);
        }

        public Task<string> SetCustomLicenseURIRequestAsync(SetCustomLicenseURIFunction setCustomLicenseURIFunction)
        {
             return ContractHandler.SendRequestAsync(setCustomLicenseURIFunction);
        }

        public Task<TransactionReceipt> SetCustomLicenseURIRequestAndWaitForReceiptAsync(SetCustomLicenseURIFunction setCustomLicenseURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setCustomLicenseURIFunction, cancellationToken);
        }

        public Task<string> SetCustomLicenseURIRequestAsync(BigInteger lordID, string newURI)
        {
            var setCustomLicenseURIFunction = new SetCustomLicenseURIFunction();
                setCustomLicenseURIFunction.LordID = lordID;
                setCustomLicenseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAsync(setCustomLicenseURIFunction);
        }

        public Task<TransactionReceipt> SetCustomLicenseURIRequestAndWaitForReceiptAsync(BigInteger lordID, string newURI, CancellationTokenSource cancellationToken = null)
        {
            var setCustomLicenseURIFunction = new SetCustomLicenseURIFunction();
                setCustomLicenseURIFunction.LordID = lordID;
                setCustomLicenseURIFunction.NewURI = newURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setCustomLicenseURIFunction, cancellationToken);
        }

        public Task<string> SetCustomLordURIRequestAsync(SetCustomLordURIFunction setCustomLordURIFunction)
        {
             return ContractHandler.SendRequestAsync(setCustomLordURIFunction);
        }

        public Task<TransactionReceipt> SetCustomLordURIRequestAndWaitForReceiptAsync(SetCustomLordURIFunction setCustomLordURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setCustomLordURIFunction, cancellationToken);
        }

        public Task<string> SetCustomLordURIRequestAsync(BigInteger lordId, string customURI)
        {
            var setCustomLordURIFunction = new SetCustomLordURIFunction();
                setCustomLordURIFunction.LordId = lordId;
                setCustomLordURIFunction.CustomURI = customURI;
            
             return ContractHandler.SendRequestAsync(setCustomLordURIFunction);
        }

        public Task<TransactionReceipt> SetCustomLordURIRequestAndWaitForReceiptAsync(BigInteger lordId, string customURI, CancellationTokenSource cancellationToken = null)
        {
            var setCustomLordURIFunction = new SetCustomLordURIFunction();
                setCustomLordURIFunction.LordId = lordId;
                setCustomLordURIFunction.CustomURI = customURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setCustomLordURIFunction, cancellationToken);
        }

        public Task<string> SetUserRequestAsync(SetUserFunction setUserFunction)
        {
             return ContractHandler.SendRequestAsync(setUserFunction);
        }

        public Task<TransactionReceipt> SetUserRequestAndWaitForReceiptAsync(SetUserFunction setUserFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setUserFunction, cancellationToken);
        }

        public Task<string> SetUserRequestAsync(BigInteger tokenId, string user, BigInteger expires)
        {
            var setUserFunction = new SetUserFunction();
                setUserFunction.TokenId = tokenId;
                setUserFunction.User = user;
                setUserFunction.Expires = expires;
            
             return ContractHandler.SendRequestAsync(setUserFunction);
        }

        public Task<TransactionReceipt> SetUserRequestAndWaitForReceiptAsync(BigInteger tokenId, string user, BigInteger expires, CancellationTokenSource cancellationToken = null)
        {
            var setUserFunction = new SetUserFunction();
                setUserFunction.TokenId = tokenId;
                setUserFunction.User = user;
                setUserFunction.Expires = expires;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setUserFunction, cancellationToken);
        }

        public Task<BigInteger> SignalLengthQueryAsync(SignalLengthFunction signalLengthFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SignalLengthFunction, BigInteger>(signalLengthFunction, blockParameter);
        }

        
        public Task<BigInteger> SignalLengthQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SignalLengthFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> SignalRebellionRequestAsync(SignalRebellionFunction signalRebellionFunction)
        {
             return ContractHandler.SendRequestAsync(signalRebellionFunction);
        }

        public Task<TransactionReceipt> SignalRebellionRequestAndWaitForReceiptAsync(SignalRebellionFunction signalRebellionFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(signalRebellionFunction, cancellationToken);
        }

        public Task<string> SignalRebellionRequestAsync(BigInteger lordID, BigInteger clanID)
        {
            var signalRebellionFunction = new SignalRebellionFunction();
                signalRebellionFunction.LordID = lordID;
                signalRebellionFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAsync(signalRebellionFunction);
        }

        public Task<TransactionReceipt> SignalRebellionRequestAndWaitForReceiptAsync(BigInteger lordID, BigInteger clanID, CancellationTokenSource cancellationToken = null)
        {
            var signalRebellionFunction = new SignalRebellionFunction();
                signalRebellionFunction.LordID = lordID;
                signalRebellionFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(signalRebellionFunction, cancellationToken);
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

        public Task<string> SymbolQueryAsync(SymbolFunction symbolFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(symbolFunction, blockParameter);
        }

        
        public Task<string> SymbolQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> TaxChangeRateQueryAsync(TaxChangeRateFunction taxChangeRateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TaxChangeRateFunction, BigInteger>(taxChangeRateFunction, blockParameter);
        }

        
        public Task<BigInteger> TaxChangeRateQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TaxChangeRateFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> TokenURIQueryAsync(TokenURIFunction tokenURIFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TokenURIFunction, string>(tokenURIFunction, blockParameter);
        }

        
        public Task<string> TokenURIQueryAsync(BigInteger lordId, BlockParameter blockParameter = null)
        {
            var tokenURIFunction = new TokenURIFunction();
                tokenURIFunction.LordId = lordId;
            
            return ContractHandler.QueryAsync<TokenURIFunction, string>(tokenURIFunction, blockParameter);
        }

        public Task<BigInteger> TotalSupplyQueryAsync(TotalSupplyFunction totalSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> TransferFromRequestAsync(TransferFromFunction transferFromFunction)
        {
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(TransferFromFunction transferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<string> TransferFromRequestAsync(string from, string to, BigInteger tokenId)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<BigInteger> UserExpiresQueryAsync(UserExpiresFunction userExpiresFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserExpiresFunction, BigInteger>(userExpiresFunction, blockParameter);
        }

        
        public Task<BigInteger> UserExpiresQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var userExpiresFunction = new UserExpiresFunction();
                userExpiresFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<UserExpiresFunction, BigInteger>(userExpiresFunction, blockParameter);
        }

        public Task<string> UserOfQueryAsync(UserOfFunction userOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserOfFunction, string>(userOfFunction, blockParameter);
        }

        
        public Task<string> UserOfQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var userOfFunction = new UserOfFunction();
                userOfFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<UserOfFunction, string>(userOfFunction, blockParameter);
        }

        public Task<BigInteger> VictoryRateQueryAsync(VictoryRateFunction victoryRateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VictoryRateFunction, BigInteger>(victoryRateFunction, blockParameter);
        }

        
        public Task<BigInteger> VictoryRateQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VictoryRateFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> ViewLordBackerFundQueryAsync(ViewLordBackerFundFunction viewLordBackerFundFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewLordBackerFundFunction, BigInteger>(viewLordBackerFundFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewLordBackerFundQueryAsync(BigInteger rebellionNumber, string backerAddress, BlockParameter blockParameter = null)
        {
            var viewLordBackerFundFunction = new ViewLordBackerFundFunction();
                viewLordBackerFundFunction.RebellionNumber = rebellionNumber;
                viewLordBackerFundFunction.BackerAddress = backerAddress;
            
            return ContractHandler.QueryAsync<ViewLordBackerFundFunction, BigInteger>(viewLordBackerFundFunction, blockParameter);
        }

        public Task<BigInteger> ViewRebelBackerFundQueryAsync(ViewRebelBackerFundFunction viewRebelBackerFundFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewRebelBackerFundFunction, BigInteger>(viewRebelBackerFundFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewRebelBackerFundQueryAsync(BigInteger rebellionNumber, string backerAddress, BlockParameter blockParameter = null)
        {
            var viewRebelBackerFundFunction = new ViewRebelBackerFundFunction();
                viewRebelBackerFundFunction.RebellionNumber = rebellionNumber;
                viewRebelBackerFundFunction.BackerAddress = backerAddress;
            
            return ContractHandler.QueryAsync<ViewRebelBackerFundFunction, BigInteger>(viewRebelBackerFundFunction, blockParameter);
        }

        public Task<BigInteger> ViewRebellionStatusQueryAsync(ViewRebellionStatusFunction viewRebellionStatusFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewRebellionStatusFunction, BigInteger>(viewRebellionStatusFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewRebellionStatusQueryAsync(BigInteger rebellionNumber, BlockParameter blockParameter = null)
        {
            var viewRebellionStatusFunction = new ViewRebellionStatusFunction();
                viewRebellionStatusFunction.RebellionNumber = rebellionNumber;
            
            return ContractHandler.QueryAsync<ViewRebellionStatusFunction, BigInteger>(viewRebellionStatusFunction, blockParameter);
        }

        public Task<BigInteger> WarCasualtyRateQueryAsync(WarCasualtyRateFunction warCasualtyRateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WarCasualtyRateFunction, BigInteger>(warCasualtyRateFunction, blockParameter);
        }

        
        public Task<BigInteger> WarCasualtyRateQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<WarCasualtyRateFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> WithdrawLpFundsRequestAsync(WithdrawLpFundsFunction withdrawLpFundsFunction)
        {
             return ContractHandler.SendRequestAsync(withdrawLpFundsFunction);
        }

        public Task<string> WithdrawLpFundsRequestAsync()
        {
             return ContractHandler.SendRequestAsync<WithdrawLpFundsFunction>();
        }

        public Task<TransactionReceipt> WithdrawLpFundsRequestAndWaitForReceiptAsync(WithdrawLpFundsFunction withdrawLpFundsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(withdrawLpFundsFunction, cancellationToken);
        }

        public Task<TransactionReceipt> WithdrawLpFundsRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<WithdrawLpFundsFunction>(null, cancellationToken);
        }
    }
}
