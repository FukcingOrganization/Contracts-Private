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
using Contracts.Contracts.Items.ContractDefinition;

namespace Contracts.Contracts.Items
{
    public partial class ItemsService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ItemsDeployment itemsDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ItemsDeployment>().SendRequestAndWaitForReceiptAsync(itemsDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ItemsDeployment itemsDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ItemsDeployment>().SendRequestAsync(itemsDeployment);
        }

        public static async Task<ItemsService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ItemsDeployment itemsDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, itemsDeployment, cancellationTokenSource);
            return new ItemsService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public ItemsService(Nethereum.Web3.Web3 web3, string contractAddress)
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

        public Task<BigInteger> BalanceOfQueryAsync(BalanceOfFunction balanceOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        
        public Task<BigInteger> BalanceOfQueryAsync(string account, BigInteger id, BlockParameter blockParameter = null)
        {
            var balanceOfFunction = new BalanceOfFunction();
                balanceOfFunction.Account = account;
                balanceOfFunction.Id = id;
            
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        public Task<List<BigInteger>> BalanceOfBatchQueryAsync(BalanceOfBatchFunction balanceOfBatchFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfBatchFunction, List<BigInteger>>(balanceOfBatchFunction, blockParameter);
        }

        
        public Task<List<BigInteger>> BalanceOfBatchQueryAsync(List<string> accounts, List<BigInteger> ids, BlockParameter blockParameter = null)
        {
            var balanceOfBatchFunction = new BalanceOfBatchFunction();
                balanceOfBatchFunction.Accounts = accounts;
                balanceOfBatchFunction.Ids = ids;
            
            return ContractHandler.QueryAsync<BalanceOfBatchFunction, List<BigInteger>>(balanceOfBatchFunction, blockParameter);
        }

        public Task<string> BurnRequestAsync(BurnFunction burnFunction)
        {
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BurnFunction burnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnRequestAsync(string account, BigInteger id, BigInteger value)
        {
            var burnFunction = new BurnFunction();
                burnFunction.Account = account;
                burnFunction.Id = id;
                burnFunction.Value = value;
            
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(string account, BigInteger id, BigInteger value, CancellationTokenSource cancellationToken = null)
        {
            var burnFunction = new BurnFunction();
                burnFunction.Account = account;
                burnFunction.Id = id;
                burnFunction.Value = value;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnBatchRequestAsync(BurnBatchFunction burnBatchFunction)
        {
             return ContractHandler.SendRequestAsync(burnBatchFunction);
        }

        public Task<TransactionReceipt> BurnBatchRequestAndWaitForReceiptAsync(BurnBatchFunction burnBatchFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnBatchFunction, cancellationToken);
        }

        public Task<string> BurnBatchRequestAsync(string account, List<BigInteger> ids, List<BigInteger> values)
        {
            var burnBatchFunction = new BurnBatchFunction();
                burnBatchFunction.Account = account;
                burnBatchFunction.Ids = ids;
                burnBatchFunction.Values = values;
            
             return ContractHandler.SendRequestAsync(burnBatchFunction);
        }

        public Task<TransactionReceipt> BurnBatchRequestAndWaitForReceiptAsync(string account, List<BigInteger> ids, List<BigInteger> values, CancellationTokenSource cancellationToken = null)
        {
            var burnBatchFunction = new BurnBatchFunction();
                burnBatchFunction.Account = account;
                burnBatchFunction.Ids = ids;
                burnBatchFunction.Values = values;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnBatchFunction, cancellationToken);
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

        public Task<string> ExecuteItemActivationProposalRequestAsync(ExecuteItemActivationProposalFunction executeItemActivationProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeItemActivationProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteItemActivationProposalRequestAndWaitForReceiptAsync(ExecuteItemActivationProposalFunction executeItemActivationProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeItemActivationProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteItemActivationProposalRequestAsync(BigInteger proposalID)
        {
            var executeItemActivationProposalFunction = new ExecuteItemActivationProposalFunction();
                executeItemActivationProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeItemActivationProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteItemActivationProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeItemActivationProposalFunction = new ExecuteItemActivationProposalFunction();
                executeItemActivationProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeItemActivationProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMintCostProposalRequestAsync(ExecuteMintCostProposalFunction executeMintCostProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeMintCostProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMintCostProposalRequestAndWaitForReceiptAsync(ExecuteMintCostProposalFunction executeMintCostProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMintCostProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMintCostProposalRequestAsync(BigInteger proposalID)
        {
            var executeMintCostProposalFunction = new ExecuteMintCostProposalFunction();
                executeMintCostProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeMintCostProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMintCostProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeMintCostProposalFunction = new ExecuteMintCostProposalFunction();
                executeMintCostProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMintCostProposalFunction, cancellationToken);
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

        public Task<bool> IsApprovedForAllQueryAsync(IsApprovedForAllFunction isApprovedForAllFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        
        public Task<bool> IsApprovedForAllQueryAsync(string account, string @operator, BlockParameter blockParameter = null)
        {
            var isApprovedForAllFunction = new IsApprovedForAllFunction();
                isApprovedForAllFunction.Account = account;
                isApprovedForAllFunction.Operator = @operator;
            
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        public Task<ItemsOutputDTO> ItemsQueryAsync(ItemsFunction itemsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ItemsFunction, ItemsOutputDTO>(itemsFunction, blockParameter);
        }

        public Task<ItemsOutputDTO> ItemsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var itemsFunction = new ItemsFunction();
                itemsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ItemsFunction, ItemsOutputDTO>(itemsFunction, blockParameter);
        }

        public Task<string> MintRequestAsync(MintFunction mintFunction)
        {
             return ContractHandler.SendRequestAsync(mintFunction);
        }

        public Task<TransactionReceipt> MintRequestAndWaitForReceiptAsync(MintFunction mintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintFunction, cancellationToken);
        }

        public Task<string> MintRequestAsync(BigInteger id, BigInteger amount, byte[] data)
        {
            var mintFunction = new MintFunction();
                mintFunction.Id = id;
                mintFunction.Amount = amount;
                mintFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(mintFunction);
        }

        public Task<TransactionReceipt> MintRequestAndWaitForReceiptAsync(BigInteger id, BigInteger amount, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var mintFunction = new MintFunction();
                mintFunction.Id = id;
                mintFunction.Amount = amount;
                mintFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintFunction, cancellationToken);
        }

        public Task<string> MintBatchRequestAsync(MintBatchFunction mintBatchFunction)
        {
             return ContractHandler.SendRequestAsync(mintBatchFunction);
        }

        public Task<TransactionReceipt> MintBatchRequestAndWaitForReceiptAsync(MintBatchFunction mintBatchFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintBatchFunction, cancellationToken);
        }

        public Task<string> MintBatchRequestAsync(string to, List<BigInteger> ids, List<BigInteger> amounts, byte[] data)
        {
            var mintBatchFunction = new MintBatchFunction();
                mintBatchFunction.To = to;
                mintBatchFunction.Ids = ids;
                mintBatchFunction.Amounts = amounts;
                mintBatchFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(mintBatchFunction);
        }

        public Task<TransactionReceipt> MintBatchRequestAndWaitForReceiptAsync(string to, List<BigInteger> ids, List<BigInteger> amounts, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var mintBatchFunction = new MintBatchFunction();
                mintBatchFunction.To = to;
                mintBatchFunction.Ids = ids;
                mintBatchFunction.Amounts = amounts;
                mintBatchFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintBatchFunction, cancellationToken);
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

        public Task<string> ProposeItemActivationUpdateRequestAsync(ProposeItemActivationUpdateFunction proposeItemActivationUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeItemActivationUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeItemActivationUpdateRequestAndWaitForReceiptAsync(ProposeItemActivationUpdateFunction proposeItemActivationUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeItemActivationUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeItemActivationUpdateRequestAsync(BigInteger itemID, bool activationStatus)
        {
            var proposeItemActivationUpdateFunction = new ProposeItemActivationUpdateFunction();
                proposeItemActivationUpdateFunction.ItemID = itemID;
                proposeItemActivationUpdateFunction.ActivationStatus = activationStatus;
            
             return ContractHandler.SendRequestAsync(proposeItemActivationUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeItemActivationUpdateRequestAndWaitForReceiptAsync(BigInteger itemID, bool activationStatus, CancellationTokenSource cancellationToken = null)
        {
            var proposeItemActivationUpdateFunction = new ProposeItemActivationUpdateFunction();
                proposeItemActivationUpdateFunction.ItemID = itemID;
                proposeItemActivationUpdateFunction.ActivationStatus = activationStatus;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeItemActivationUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMintCostUpdateRequestAsync(ProposeMintCostUpdateFunction proposeMintCostUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMintCostUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMintCostUpdateRequestAndWaitForReceiptAsync(ProposeMintCostUpdateFunction proposeMintCostUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMintCostUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMintCostUpdateRequestAsync(BigInteger itemID, BigInteger newCost)
        {
            var proposeMintCostUpdateFunction = new ProposeMintCostUpdateFunction();
                proposeMintCostUpdateFunction.ItemID = itemID;
                proposeMintCostUpdateFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAsync(proposeMintCostUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMintCostUpdateRequestAndWaitForReceiptAsync(BigInteger itemID, BigInteger newCost, CancellationTokenSource cancellationToken = null)
        {
            var proposeMintCostUpdateFunction = new ProposeMintCostUpdateFunction();
                proposeMintCostUpdateFunction.ItemID = itemID;
                proposeMintCostUpdateFunction.NewCost = newCost;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMintCostUpdateFunction, cancellationToken);
        }

        public Task<string> SafeBatchTransferFromRequestAsync(SafeBatchTransferFromFunction safeBatchTransferFromFunction)
        {
             return ContractHandler.SendRequestAsync(safeBatchTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeBatchTransferFromRequestAndWaitForReceiptAsync(SafeBatchTransferFromFunction safeBatchTransferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeBatchTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeBatchTransferFromRequestAsync(string from, string to, List<BigInteger> ids, List<BigInteger> amounts, byte[] data)
        {
            var safeBatchTransferFromFunction = new SafeBatchTransferFromFunction();
                safeBatchTransferFromFunction.From = from;
                safeBatchTransferFromFunction.To = to;
                safeBatchTransferFromFunction.Ids = ids;
                safeBatchTransferFromFunction.Amounts = amounts;
                safeBatchTransferFromFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(safeBatchTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeBatchTransferFromRequestAndWaitForReceiptAsync(string from, string to, List<BigInteger> ids, List<BigInteger> amounts, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var safeBatchTransferFromFunction = new SafeBatchTransferFromFunction();
                safeBatchTransferFromFunction.From = from;
                safeBatchTransferFromFunction.To = to;
                safeBatchTransferFromFunction.Ids = ids;
                safeBatchTransferFromFunction.Amounts = amounts;
                safeBatchTransferFromFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeBatchTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(SafeTransferFromFunction safeTransferFromFunction)
        {
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(SafeTransferFromFunction safeTransferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(string from, string to, BigInteger id, BigInteger amount, byte[] data)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.Id = id;
                safeTransferFromFunction.Amount = amount;
                safeTransferFromFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger id, BigInteger amount, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.Id = id;
                safeTransferFromFunction.Amount = amount;
                safeTransferFromFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
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

        public Task<string> SetTokenURIRequestAsync(SetTokenURIFunction setTokenURIFunction)
        {
             return ContractHandler.SendRequestAsync(setTokenURIFunction);
        }

        public Task<TransactionReceipt> SetTokenURIRequestAndWaitForReceiptAsync(SetTokenURIFunction setTokenURIFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setTokenURIFunction, cancellationToken);
        }

        public Task<string> SetTokenURIRequestAsync(BigInteger tokenID, string tokenURI)
        {
            var setTokenURIFunction = new SetTokenURIFunction();
                setTokenURIFunction.TokenID = tokenID;
                setTokenURIFunction.TokenURI = tokenURI;
            
             return ContractHandler.SendRequestAsync(setTokenURIFunction);
        }

        public Task<TransactionReceipt> SetTokenURIRequestAndWaitForReceiptAsync(BigInteger tokenID, string tokenURI, CancellationTokenSource cancellationToken = null)
        {
            var setTokenURIFunction = new SetTokenURIFunction();
                setTokenURIFunction.TokenID = tokenID;
                setTokenURIFunction.TokenURI = tokenURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setTokenURIFunction, cancellationToken);
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

        public Task<BigInteger> TotalSupplyQueryAsync(TotalSupplyFunction totalSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyQueryAsync(BigInteger tokenID, BlockParameter blockParameter = null)
        {
            var totalSupplyFunction = new TotalSupplyFunction();
                totalSupplyFunction.TokenID = tokenID;
            
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        public Task<string> UriQueryAsync(UriFunction uriFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UriFunction, string>(uriFunction, blockParameter);
        }

        
        public Task<string> UriQueryAsync(BigInteger tokenID, BlockParameter blockParameter = null)
        {
            var uriFunction = new UriFunction();
                uriFunction.TokenID = tokenID;
            
            return ContractHandler.QueryAsync<UriFunction, string>(uriFunction, blockParameter);
        }
    }
}
