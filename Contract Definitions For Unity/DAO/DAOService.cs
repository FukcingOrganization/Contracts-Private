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
using Contracts.Contracts.DAO.ContractDefinition;

namespace Contracts.Contracts.DAO
{
    public partial class DAOService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, DAODeployment dAODeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<DAODeployment>().SendRequestAndWaitForReceiptAsync(dAODeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, DAODeployment dAODeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<DAODeployment>().SendRequestAsync(dAODeployment);
        }

        public static async Task<DAOService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, DAODeployment dAODeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, dAODeployment, cancellationTokenSource);
            return new DAOService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public DAOService(Nethereum.Web3.Web3 web3, string contractAddress)
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

        public Task<BigInteger> AllowanceQueryAsync(AllowanceFunction allowanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AllowanceFunction, BigInteger>(allowanceFunction, blockParameter);
        }

        
        public Task<BigInteger> AllowanceQueryAsync(string owner, string spender, BlockParameter blockParameter = null)
        {
            var allowanceFunction = new AllowanceFunction();
                allowanceFunction.Owner = owner;
                allowanceFunction.Spender = spender;
            
            return ContractHandler.QueryAsync<AllowanceFunction, BigInteger>(allowanceFunction, blockParameter);
        }

        public Task<string> ApproveRequestAsync(ApproveFunction approveFunction)
        {
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(ApproveFunction approveFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<string> ApproveRequestAsync(string spender, BigInteger amount)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.Spender = spender;
                approveFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(string spender, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.Spender = spender;
                approveFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<BigInteger> BalanceOfQueryAsync(BalanceOfFunction balanceOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        
        public Task<BigInteger> BalanceOfQueryAsync(string account, BlockParameter blockParameter = null)
        {
            var balanceOfFunction = new BalanceOfFunction();
                balanceOfFunction.Account = account;
            
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        public Task<string> ClaimCoinSpendingRequestAsync(ClaimCoinSpendingFunction claimCoinSpendingFunction)
        {
             return ContractHandler.SendRequestAsync(claimCoinSpendingFunction);
        }

        public Task<TransactionReceipt> ClaimCoinSpendingRequestAndWaitForReceiptAsync(ClaimCoinSpendingFunction claimCoinSpendingFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimCoinSpendingFunction, cancellationToken);
        }

        public Task<string> ClaimCoinSpendingRequestAsync(BigInteger spendingProposalNumber, List<byte[]> merkleProof)
        {
            var claimCoinSpendingFunction = new ClaimCoinSpendingFunction();
                claimCoinSpendingFunction.SpendingProposalNumber = spendingProposalNumber;
                claimCoinSpendingFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAsync(claimCoinSpendingFunction);
        }

        public Task<TransactionReceipt> ClaimCoinSpendingRequestAndWaitForReceiptAsync(BigInteger spendingProposalNumber, List<byte[]> merkleProof, CancellationTokenSource cancellationToken = null)
        {
            var claimCoinSpendingFunction = new ClaimCoinSpendingFunction();
                claimCoinSpendingFunction.SpendingProposalNumber = spendingProposalNumber;
                claimCoinSpendingFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimCoinSpendingFunction, cancellationToken);
        }

        public Task<string> ClaimTokenSpendingRequestAsync(ClaimTokenSpendingFunction claimTokenSpendingFunction)
        {
             return ContractHandler.SendRequestAsync(claimTokenSpendingFunction);
        }

        public Task<TransactionReceipt> ClaimTokenSpendingRequestAndWaitForReceiptAsync(ClaimTokenSpendingFunction claimTokenSpendingFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimTokenSpendingFunction, cancellationToken);
        }

        public Task<string> ClaimTokenSpendingRequestAsync(BigInteger spendingProposalNumber, List<byte[]> merkleProof)
        {
            var claimTokenSpendingFunction = new ClaimTokenSpendingFunction();
                claimTokenSpendingFunction.SpendingProposalNumber = spendingProposalNumber;
                claimTokenSpendingFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAsync(claimTokenSpendingFunction);
        }

        public Task<TransactionReceipt> ClaimTokenSpendingRequestAndWaitForReceiptAsync(BigInteger spendingProposalNumber, List<byte[]> merkleProof, CancellationTokenSource cancellationToken = null)
        {
            var claimTokenSpendingFunction = new ClaimTokenSpendingFunction();
                claimTokenSpendingFunction.SpendingProposalNumber = spendingProposalNumber;
                claimTokenSpendingFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimTokenSpendingFunction, cancellationToken);
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

        public Task<byte> DecimalsQueryAsync(DecimalsFunction decimalsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DecimalsFunction, byte>(decimalsFunction, blockParameter);
        }

        
        public Task<byte> DecimalsQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DecimalsFunction, byte>(null, blockParameter);
        }

        public Task<string> DecreaseAllowanceRequestAsync(DecreaseAllowanceFunction decreaseAllowanceFunction)
        {
             return ContractHandler.SendRequestAsync(decreaseAllowanceFunction);
        }

        public Task<TransactionReceipt> DecreaseAllowanceRequestAndWaitForReceiptAsync(DecreaseAllowanceFunction decreaseAllowanceFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(decreaseAllowanceFunction, cancellationToken);
        }

        public Task<string> DecreaseAllowanceRequestAsync(string spender, BigInteger subtractedValue)
        {
            var decreaseAllowanceFunction = new DecreaseAllowanceFunction();
                decreaseAllowanceFunction.Spender = spender;
                decreaseAllowanceFunction.SubtractedValue = subtractedValue;
            
             return ContractHandler.SendRequestAsync(decreaseAllowanceFunction);
        }

        public Task<TransactionReceipt> DecreaseAllowanceRequestAndWaitForReceiptAsync(string spender, BigInteger subtractedValue, CancellationTokenSource cancellationToken = null)
        {
            var decreaseAllowanceFunction = new DecreaseAllowanceFunction();
                decreaseAllowanceFunction.Spender = spender;
                decreaseAllowanceFunction.SubtractedValue = subtractedValue;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(decreaseAllowanceFunction, cancellationToken);
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

        public Task<string> ExecuteMinBalanceToPropUpdateProposalRequestAsync(ExecuteMinBalanceToPropUpdateProposalFunction executeMinBalanceToPropUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeMinBalanceToPropUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMinBalanceToPropUpdateProposalRequestAndWaitForReceiptAsync(ExecuteMinBalanceToPropUpdateProposalFunction executeMinBalanceToPropUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMinBalanceToPropUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMinBalanceToPropUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeMinBalanceToPropUpdateProposalFunction = new ExecuteMinBalanceToPropUpdateProposalFunction();
                executeMinBalanceToPropUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeMinBalanceToPropUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMinBalanceToPropUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeMinBalanceToPropUpdateProposalFunction = new ExecuteMinBalanceToPropUpdateProposalFunction();
                executeMinBalanceToPropUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMinBalanceToPropUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteNewProposalTypeProposalRequestAsync(ExecuteNewProposalTypeProposalFunction executeNewProposalTypeProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeNewProposalTypeProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteNewProposalTypeProposalRequestAndWaitForReceiptAsync(ExecuteNewProposalTypeProposalFunction executeNewProposalTypeProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeNewProposalTypeProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteNewProposalTypeProposalRequestAsync(BigInteger proposalID)
        {
            var executeNewProposalTypeProposalFunction = new ExecuteNewProposalTypeProposalFunction();
                executeNewProposalTypeProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeNewProposalTypeProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteNewProposalTypeProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeNewProposalTypeProposalFunction = new ExecuteNewProposalTypeProposalFunction();
                executeNewProposalTypeProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeNewProposalTypeProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteProposalTypeUpdateProposalRequestAsync(ExecuteProposalTypeUpdateProposalFunction executeProposalTypeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeProposalTypeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteProposalTypeUpdateProposalRequestAndWaitForReceiptAsync(ExecuteProposalTypeUpdateProposalFunction executeProposalTypeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeProposalTypeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteProposalTypeUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeProposalTypeUpdateProposalFunction = new ExecuteProposalTypeUpdateProposalFunction();
                executeProposalTypeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeProposalTypeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteProposalTypeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeProposalTypeUpdateProposalFunction = new ExecuteProposalTypeUpdateProposalFunction();
                executeProposalTypeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeProposalTypeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> FinalizeSpendingProposalRequestAsync(FinalizeSpendingProposalFunction finalizeSpendingProposalFunction)
        {
             return ContractHandler.SendRequestAsync(finalizeSpendingProposalFunction);
        }

        public Task<string> FinalizeSpendingProposalRequestAsync()
        {
             return ContractHandler.SendRequestAsync<FinalizeSpendingProposalFunction>();
        }

        public Task<TransactionReceipt> FinalizeSpendingProposalRequestAndWaitForReceiptAsync(FinalizeSpendingProposalFunction finalizeSpendingProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(finalizeSpendingProposalFunction, cancellationToken);
        }

        public Task<TransactionReceipt> FinalizeSpendingProposalRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<FinalizeSpendingProposalFunction>(null, cancellationToken);
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

        public Task<BigInteger> GetContractCoinBalanceQueryAsync(GetContractCoinBalanceFunction getContractCoinBalanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetContractCoinBalanceFunction, BigInteger>(getContractCoinBalanceFunction, blockParameter);
        }

        
        public Task<BigInteger> GetContractCoinBalanceQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetContractCoinBalanceFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> GetContractTokenBalanceQueryAsync(GetContractTokenBalanceFunction getContractTokenBalanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetContractTokenBalanceFunction, BigInteger>(getContractTokenBalanceFunction, blockParameter);
        }

        
        public Task<BigInteger> GetContractTokenBalanceQueryAsync(string tokenContractAddress, BlockParameter blockParameter = null)
        {
            var getContractTokenBalanceFunction = new GetContractTokenBalanceFunction();
                getContractTokenBalanceFunction.TokenContractAddress = tokenContractAddress;
            
            return ContractHandler.QueryAsync<GetContractTokenBalanceFunction, BigInteger>(getContractTokenBalanceFunction, blockParameter);
        }

        public Task<BigInteger> GetMinBalanceToProposeQueryAsync(GetMinBalanceToProposeFunction getMinBalanceToProposeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetMinBalanceToProposeFunction, BigInteger>(getMinBalanceToProposeFunction, blockParameter);
        }

        
        public Task<BigInteger> GetMinBalanceToProposeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetMinBalanceToProposeFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> IncreaseAllowanceRequestAsync(IncreaseAllowanceFunction increaseAllowanceFunction)
        {
             return ContractHandler.SendRequestAsync(increaseAllowanceFunction);
        }

        public Task<TransactionReceipt> IncreaseAllowanceRequestAndWaitForReceiptAsync(IncreaseAllowanceFunction increaseAllowanceFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(increaseAllowanceFunction, cancellationToken);
        }

        public Task<string> IncreaseAllowanceRequestAsync(string spender, BigInteger addedValue)
        {
            var increaseAllowanceFunction = new IncreaseAllowanceFunction();
                increaseAllowanceFunction.Spender = spender;
                increaseAllowanceFunction.AddedValue = addedValue;
            
             return ContractHandler.SendRequestAsync(increaseAllowanceFunction);
        }

        public Task<TransactionReceipt> IncreaseAllowanceRequestAndWaitForReceiptAsync(string spender, BigInteger addedValue, CancellationTokenSource cancellationToken = null)
        {
            var increaseAllowanceFunction = new IncreaseAllowanceFunction();
                increaseAllowanceFunction.Spender = spender;
                increaseAllowanceFunction.AddedValue = addedValue;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(increaseAllowanceFunction, cancellationToken);
        }

        public Task<string> IsProposalPassedRequestAsync(IsProposalPassedFunction isProposalPassedFunction)
        {
             return ContractHandler.SendRequestAsync(isProposalPassedFunction);
        }

        public Task<TransactionReceipt> IsProposalPassedRequestAndWaitForReceiptAsync(IsProposalPassedFunction isProposalPassedFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(isProposalPassedFunction, cancellationToken);
        }

        public Task<string> IsProposalPassedRequestAsync(BigInteger proposalID)
        {
            var isProposalPassedFunction = new IsProposalPassedFunction();
                isProposalPassedFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(isProposalPassedFunction);
        }

        public Task<TransactionReceipt> IsProposalPassedRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var isProposalPassedFunction = new IsProposalPassedFunction();
                isProposalPassedFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(isProposalPassedFunction, cancellationToken);
        }

        public Task<string> LordVoteRequestAsync(LordVoteFunction lordVoteFunction)
        {
             return ContractHandler.SendRequestAsync(lordVoteFunction);
        }

        public Task<TransactionReceipt> LordVoteRequestAndWaitForReceiptAsync(LordVoteFunction lordVoteFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(lordVoteFunction, cancellationToken);
        }

        public Task<string> LordVoteRequestAsync(BigInteger proposalID, bool isApproving, BigInteger lordID, BigInteger lordTotalSupply)
        {
            var lordVoteFunction = new LordVoteFunction();
                lordVoteFunction.ProposalID = proposalID;
                lordVoteFunction.IsApproving = isApproving;
                lordVoteFunction.LordID = lordID;
                lordVoteFunction.LordTotalSupply = lordTotalSupply;
            
             return ContractHandler.SendRequestAsync(lordVoteFunction);
        }

        public Task<TransactionReceipt> LordVoteRequestAndWaitForReceiptAsync(BigInteger proposalID, bool isApproving, BigInteger lordID, BigInteger lordTotalSupply, CancellationTokenSource cancellationToken = null)
        {
            var lordVoteFunction = new LordVoteFunction();
                lordVoteFunction.ProposalID = proposalID;
                lordVoteFunction.IsApproving = isApproving;
                lordVoteFunction.LordID = lordID;
                lordVoteFunction.LordTotalSupply = lordTotalSupply;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(lordVoteFunction, cancellationToken);
        }

        public Task<BigInteger> MinBalanceToProposeQueryAsync(MinBalanceToProposeFunction minBalanceToProposeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinBalanceToProposeFunction, BigInteger>(minBalanceToProposeFunction, blockParameter);
        }

        
        public Task<BigInteger> MinBalanceToProposeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinBalanceToProposeFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> MintTokensRequestAsync(MintTokensFunction mintTokensFunction)
        {
             return ContractHandler.SendRequestAsync(mintTokensFunction);
        }

        public Task<TransactionReceipt> MintTokensRequestAndWaitForReceiptAsync(MintTokensFunction mintTokensFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintTokensFunction, cancellationToken);
        }

        public Task<string> MintTokensRequestAsync(string minter, BigInteger amount)
        {
            var mintTokensFunction = new MintTokensFunction();
                mintTokensFunction.Minter = minter;
                mintTokensFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(mintTokensFunction);
        }

        public Task<TransactionReceipt> MintTokensRequestAndWaitForReceiptAsync(string minter, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var mintTokensFunction = new MintTokensFunction();
                mintTokensFunction.Minter = minter;
                mintTokensFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintTokensFunction, cancellationToken);
        }

        public Task<string> NameQueryAsync(NameFunction nameFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(nameFunction, blockParameter);
        }

        
        public Task<string> NameQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(null, blockParameter);
        }

        public Task<string> NewProposalRequestAsync(NewProposalFunction newProposalFunction)
        {
             return ContractHandler.SendRequestAsync(newProposalFunction);
        }

        public Task<TransactionReceipt> NewProposalRequestAndWaitForReceiptAsync(NewProposalFunction newProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(newProposalFunction, cancellationToken);
        }

        public Task<string> NewProposalRequestAsync(string description, BigInteger proposalType)
        {
            var newProposalFunction = new NewProposalFunction();
                newProposalFunction.Description = description;
                newProposalFunction.ProposalType = proposalType;
            
             return ContractHandler.SendRequestAsync(newProposalFunction);
        }

        public Task<TransactionReceipt> NewProposalRequestAndWaitForReceiptAsync(string description, BigInteger proposalType, CancellationTokenSource cancellationToken = null)
        {
            var newProposalFunction = new NewProposalFunction();
                newProposalFunction.Description = description;
                newProposalFunction.ProposalType = proposalType;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(newProposalFunction, cancellationToken);
        }

        public Task<string> ProposalResultRequestAsync(ProposalResultFunction proposalResultFunction)
        {
             return ContractHandler.SendRequestAsync(proposalResultFunction);
        }

        public Task<TransactionReceipt> ProposalResultRequestAndWaitForReceiptAsync(ProposalResultFunction proposalResultFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposalResultFunction, cancellationToken);
        }

        public Task<string> ProposalResultRequestAsync(BigInteger proposalID)
        {
            var proposalResultFunction = new ProposalResultFunction();
                proposalResultFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(proposalResultFunction);
        }

        public Task<TransactionReceipt> ProposalResultRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var proposalResultFunction = new ProposalResultFunction();
                proposalResultFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposalResultFunction, cancellationToken);
        }

        public Task<ProposalTrackersOutputDTO> ProposalTrackersQueryAsync(ProposalTrackersFunction proposalTrackersFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTrackersFunction, ProposalTrackersOutputDTO>(proposalTrackersFunction, blockParameter);
        }

        public Task<ProposalTrackersOutputDTO> ProposalTrackersQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var proposalTrackersFunction = new ProposalTrackersFunction();
                proposalTrackersFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTrackersFunction, ProposalTrackersOutputDTO>(proposalTrackersFunction, blockParameter);
        }

        public Task<ProposalTypeUpdatesOutputDTO> ProposalTypeUpdatesQueryAsync(ProposalTypeUpdatesFunction proposalTypeUpdatesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTypeUpdatesFunction, ProposalTypeUpdatesOutputDTO>(proposalTypeUpdatesFunction, blockParameter);
        }

        public Task<ProposalTypeUpdatesOutputDTO> ProposalTypeUpdatesQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var proposalTypeUpdatesFunction = new ProposalTypeUpdatesFunction();
                proposalTypeUpdatesFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTypeUpdatesFunction, ProposalTypeUpdatesOutputDTO>(proposalTypeUpdatesFunction, blockParameter);
        }

        public Task<ProposalTypesOutputDTO> ProposalTypesQueryAsync(ProposalTypesFunction proposalTypesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTypesFunction, ProposalTypesOutputDTO>(proposalTypesFunction, blockParameter);
        }

        public Task<ProposalTypesOutputDTO> ProposalTypesQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var proposalTypesFunction = new ProposalTypesFunction();
                proposalTypesFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ProposalTypesFunction, ProposalTypesOutputDTO>(proposalTypesFunction, blockParameter);
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

        public Task<string> ProposeMinBalanceToPropUpdateRequestAsync(ProposeMinBalanceToPropUpdateFunction proposeMinBalanceToPropUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMinBalanceToPropUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMinBalanceToPropUpdateRequestAndWaitForReceiptAsync(ProposeMinBalanceToPropUpdateFunction proposeMinBalanceToPropUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMinBalanceToPropUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMinBalanceToPropUpdateRequestAsync(BigInteger newAmount)
        {
            var proposeMinBalanceToPropUpdateFunction = new ProposeMinBalanceToPropUpdateFunction();
                proposeMinBalanceToPropUpdateFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAsync(proposeMinBalanceToPropUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMinBalanceToPropUpdateRequestAndWaitForReceiptAsync(BigInteger newAmount, CancellationTokenSource cancellationToken = null)
        {
            var proposeMinBalanceToPropUpdateFunction = new ProposeMinBalanceToPropUpdateFunction();
                proposeMinBalanceToPropUpdateFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMinBalanceToPropUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeNewCoinSpendingRequestAsync(ProposeNewCoinSpendingFunction proposeNewCoinSpendingFunction)
        {
             return ContractHandler.SendRequestAsync(proposeNewCoinSpendingFunction);
        }

        public Task<TransactionReceipt> ProposeNewCoinSpendingRequestAndWaitForReceiptAsync(ProposeNewCoinSpendingFunction proposeNewCoinSpendingFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewCoinSpendingFunction, cancellationToken);
        }

        public Task<string> ProposeNewCoinSpendingRequestAsync(List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending)
        {
            var proposeNewCoinSpendingFunction = new ProposeNewCoinSpendingFunction();
                proposeNewCoinSpendingFunction.MerkleRoots = merkleRoots;
                proposeNewCoinSpendingFunction.Allowances = allowances;
                proposeNewCoinSpendingFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAsync(proposeNewCoinSpendingFunction);
        }

        public Task<TransactionReceipt> ProposeNewCoinSpendingRequestAndWaitForReceiptAsync(List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending, CancellationTokenSource cancellationToken = null)
        {
            var proposeNewCoinSpendingFunction = new ProposeNewCoinSpendingFunction();
                proposeNewCoinSpendingFunction.MerkleRoots = merkleRoots;
                proposeNewCoinSpendingFunction.Allowances = allowances;
                proposeNewCoinSpendingFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewCoinSpendingFunction, cancellationToken);
        }

        public Task<string> ProposeNewProposalTypeRequestAsync(ProposeNewProposalTypeFunction proposeNewProposalTypeFunction)
        {
             return ContractHandler.SendRequestAsync(proposeNewProposalTypeFunction);
        }

        public Task<TransactionReceipt> ProposeNewProposalTypeRequestAndWaitForReceiptAsync(ProposeNewProposalTypeFunction proposeNewProposalTypeFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewProposalTypeFunction, cancellationToken);
        }

        public Task<string> ProposeNewProposalTypeRequestAsync(BigInteger length, BigInteger requiredApprovalRate, BigInteger requiredTokenAmount, BigInteger requiredParticipantAmount)
        {
            var proposeNewProposalTypeFunction = new ProposeNewProposalTypeFunction();
                proposeNewProposalTypeFunction.Length = length;
                proposeNewProposalTypeFunction.RequiredApprovalRate = requiredApprovalRate;
                proposeNewProposalTypeFunction.RequiredTokenAmount = requiredTokenAmount;
                proposeNewProposalTypeFunction.RequiredParticipantAmount = requiredParticipantAmount;
            
             return ContractHandler.SendRequestAsync(proposeNewProposalTypeFunction);
        }

        public Task<TransactionReceipt> ProposeNewProposalTypeRequestAndWaitForReceiptAsync(BigInteger length, BigInteger requiredApprovalRate, BigInteger requiredTokenAmount, BigInteger requiredParticipantAmount, CancellationTokenSource cancellationToken = null)
        {
            var proposeNewProposalTypeFunction = new ProposeNewProposalTypeFunction();
                proposeNewProposalTypeFunction.Length = length;
                proposeNewProposalTypeFunction.RequiredApprovalRate = requiredApprovalRate;
                proposeNewProposalTypeFunction.RequiredTokenAmount = requiredTokenAmount;
                proposeNewProposalTypeFunction.RequiredParticipantAmount = requiredParticipantAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewProposalTypeFunction, cancellationToken);
        }

        public Task<string> ProposeNewTokenSpendingRequestAsync(ProposeNewTokenSpendingFunction proposeNewTokenSpendingFunction)
        {
             return ContractHandler.SendRequestAsync(proposeNewTokenSpendingFunction);
        }

        public Task<TransactionReceipt> ProposeNewTokenSpendingRequestAndWaitForReceiptAsync(ProposeNewTokenSpendingFunction proposeNewTokenSpendingFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewTokenSpendingFunction, cancellationToken);
        }

        public Task<string> ProposeNewTokenSpendingRequestAsync(string tokenContractAddress, List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending)
        {
            var proposeNewTokenSpendingFunction = new ProposeNewTokenSpendingFunction();
                proposeNewTokenSpendingFunction.TokenContractAddress = tokenContractAddress;
                proposeNewTokenSpendingFunction.MerkleRoots = merkleRoots;
                proposeNewTokenSpendingFunction.Allowances = allowances;
                proposeNewTokenSpendingFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAsync(proposeNewTokenSpendingFunction);
        }

        public Task<TransactionReceipt> ProposeNewTokenSpendingRequestAndWaitForReceiptAsync(string tokenContractAddress, List<byte[]> merkleRoots, List<BigInteger> allowances, BigInteger totalSpending, CancellationTokenSource cancellationToken = null)
        {
            var proposeNewTokenSpendingFunction = new ProposeNewTokenSpendingFunction();
                proposeNewTokenSpendingFunction.TokenContractAddress = tokenContractAddress;
                proposeNewTokenSpendingFunction.MerkleRoots = merkleRoots;
                proposeNewTokenSpendingFunction.Allowances = allowances;
                proposeNewTokenSpendingFunction.TotalSpending = totalSpending;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeNewTokenSpendingFunction, cancellationToken);
        }

        public Task<string> ProposeProposalTypeUpdateRequestAsync(ProposeProposalTypeUpdateFunction proposeProposalTypeUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeProposalTypeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeProposalTypeUpdateRequestAndWaitForReceiptAsync(ProposeProposalTypeUpdateFunction proposeProposalTypeUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeProposalTypeUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeProposalTypeUpdateRequestAsync(BigInteger proposalTypeNumber, BigInteger newLength, BigInteger newRequiredApprovalRate, BigInteger newRequiredTokenAmount, BigInteger newRequiredParticipantAmount)
        {
            var proposeProposalTypeUpdateFunction = new ProposeProposalTypeUpdateFunction();
                proposeProposalTypeUpdateFunction.ProposalTypeNumber = proposalTypeNumber;
                proposeProposalTypeUpdateFunction.NewLength = newLength;
                proposeProposalTypeUpdateFunction.NewRequiredApprovalRate = newRequiredApprovalRate;
                proposeProposalTypeUpdateFunction.NewRequiredTokenAmount = newRequiredTokenAmount;
                proposeProposalTypeUpdateFunction.NewRequiredParticipantAmount = newRequiredParticipantAmount;
            
             return ContractHandler.SendRequestAsync(proposeProposalTypeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeProposalTypeUpdateRequestAndWaitForReceiptAsync(BigInteger proposalTypeNumber, BigInteger newLength, BigInteger newRequiredApprovalRate, BigInteger newRequiredTokenAmount, BigInteger newRequiredParticipantAmount, CancellationTokenSource cancellationToken = null)
        {
            var proposeProposalTypeUpdateFunction = new ProposeProposalTypeUpdateFunction();
                proposeProposalTypeUpdateFunction.ProposalTypeNumber = proposalTypeNumber;
                proposeProposalTypeUpdateFunction.NewLength = newLength;
                proposeProposalTypeUpdateFunction.NewRequiredApprovalRate = newRequiredApprovalRate;
                proposeProposalTypeUpdateFunction.NewRequiredTokenAmount = newRequiredTokenAmount;
                proposeProposalTypeUpdateFunction.NewRequiredParticipantAmount = newRequiredParticipantAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeProposalTypeUpdateFunction, cancellationToken);
        }

        public Task<List<BigInteger>> ReturnAllowancesQueryAsync(ReturnAllowancesFunction returnAllowancesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReturnAllowancesFunction, List<BigInteger>>(returnAllowancesFunction, blockParameter);
        }

        
        public Task<List<BigInteger>> ReturnAllowancesQueryAsync(BigInteger spendingProposalNumber, BlockParameter blockParameter = null)
        {
            var returnAllowancesFunction = new ReturnAllowancesFunction();
                returnAllowancesFunction.SpendingProposalNumber = spendingProposalNumber;
            
            return ContractHandler.QueryAsync<ReturnAllowancesFunction, List<BigInteger>>(returnAllowancesFunction, blockParameter);
        }

        public Task<List<byte[]>> ReturnMerkleRootsQueryAsync(ReturnMerkleRootsFunction returnMerkleRootsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ReturnMerkleRootsFunction, List<byte[]>>(returnMerkleRootsFunction, blockParameter);
        }

        
        public Task<List<byte[]>> ReturnMerkleRootsQueryAsync(BigInteger spendingProposalNumber, BlockParameter blockParameter = null)
        {
            var returnMerkleRootsFunction = new ReturnMerkleRootsFunction();
                returnMerkleRootsFunction.SpendingProposalNumber = spendingProposalNumber;
            
            return ContractHandler.QueryAsync<ReturnMerkleRootsFunction, List<byte[]>>(returnMerkleRootsFunction, blockParameter);
        }

        public Task<SpendingProposalsOutputDTO> SpendingProposalsQueryAsync(SpendingProposalsFunction spendingProposalsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<SpendingProposalsFunction, SpendingProposalsOutputDTO>(spendingProposalsFunction, blockParameter);
        }

        public Task<SpendingProposalsOutputDTO> SpendingProposalsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var spendingProposalsFunction = new SpendingProposalsFunction();
                spendingProposalsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<SpendingProposalsFunction, SpendingProposalsOutputDTO>(spendingProposalsFunction, blockParameter);
        }

        public Task<string> SymbolQueryAsync(SymbolFunction symbolFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(symbolFunction, blockParameter);
        }

        
        public Task<string> SymbolQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> TotalSupplyQueryAsync(TotalSupplyFunction totalSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> TransferRequestAsync(TransferFunction transferFunction)
        {
             return ContractHandler.SendRequestAsync(transferFunction);
        }

        public Task<TransactionReceipt> TransferRequestAndWaitForReceiptAsync(TransferFunction transferFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFunction, cancellationToken);
        }

        public Task<string> TransferRequestAsync(string to, BigInteger amount)
        {
            var transferFunction = new TransferFunction();
                transferFunction.To = to;
                transferFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(transferFunction);
        }

        public Task<TransactionReceipt> TransferRequestAndWaitForReceiptAsync(string to, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var transferFunction = new TransferFunction();
                transferFunction.To = to;
                transferFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFunction, cancellationToken);
        }

        public Task<string> TransferFromRequestAsync(TransferFromFunction transferFromFunction)
        {
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(TransferFromFunction transferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<string> TransferFromRequestAsync(string from, string to, BigInteger amount)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<string> VoteRequestAsync(VoteFunction voteFunction)
        {
             return ContractHandler.SendRequestAsync(voteFunction);
        }

        public Task<TransactionReceipt> VoteRequestAndWaitForReceiptAsync(VoteFunction voteFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(voteFunction, cancellationToken);
        }

        public Task<string> VoteRequestAsync(BigInteger proposalID, bool isApproving)
        {
            var voteFunction = new VoteFunction();
                voteFunction.ProposalID = proposalID;
                voteFunction.IsApproving = isApproving;
            
             return ContractHandler.SendRequestAsync(voteFunction);
        }

        public Task<TransactionReceipt> VoteRequestAndWaitForReceiptAsync(BigInteger proposalID, bool isApproving, CancellationTokenSource cancellationToken = null)
        {
            var voteFunction = new VoteFunction();
                voteFunction.ProposalID = proposalID;
                voteFunction.IsApproving = isApproving;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(voteFunction, cancellationToken);
        }
    }
}
