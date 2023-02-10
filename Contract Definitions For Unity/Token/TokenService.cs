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
using Contracts.Contracts.Token.ContractDefinition;

namespace Contracts.Contracts.Token
{
    public partial class TokenService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, TokenDeployment tokenDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<TokenDeployment>().SendRequestAndWaitForReceiptAsync(tokenDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, TokenDeployment tokenDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<TokenDeployment>().SendRequestAsync(tokenDeployment);
        }

        public static async Task<TokenService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, TokenDeployment tokenDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, tokenDeployment, cancellationTokenSource);
            return new TokenService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public TokenService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }

        public Task<string> DEBUG_mintTestTokenRequestAsync(DEBUG_mintTestTokenFunction dEBUG_mintTestTokenFunction)
        {
             return ContractHandler.SendRequestAsync(dEBUG_mintTestTokenFunction);
        }

        public Task<TransactionReceipt> DEBUG_mintTestTokenRequestAndWaitForReceiptAsync(DEBUG_mintTestTokenFunction dEBUG_mintTestTokenFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_mintTestTokenFunction, cancellationToken);
        }

        public Task<string> DEBUG_mintTestTokenRequestAsync(BigInteger amountInEther)
        {
            var dEBUG_mintTestTokenFunction = new DEBUG_mintTestTokenFunction();
                dEBUG_mintTestTokenFunction.AmountInEther = amountInEther;
            
             return ContractHandler.SendRequestAsync(dEBUG_mintTestTokenFunction);
        }

        public Task<TransactionReceipt> DEBUG_mintTestTokenRequestAndWaitForReceiptAsync(BigInteger amountInEther, CancellationTokenSource cancellationToken = null)
        {
            var dEBUG_mintTestTokenFunction = new DEBUG_mintTestTokenFunction();
                dEBUG_mintTestTokenFunction.AmountInEther = amountInEther;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(dEBUG_mintTestTokenFunction, cancellationToken);
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

        public Task<BigInteger> AllowancePerSecondQueryAsync(AllowancePerSecondFunction allowancePerSecondFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AllowancePerSecondFunction, BigInteger>(allowancePerSecondFunction, blockParameter);
        }

        
        public Task<BigInteger> AllowancePerSecondQueryAsync(string returnValue1, BlockParameter blockParameter = null)
        {
            var allowancePerSecondFunction = new AllowancePerSecondFunction();
                allowancePerSecondFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<AllowancePerSecondFunction, BigInteger>(allowancePerSecondFunction, blockParameter);
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

        public Task<BigInteger> AvailableCommunityMintQueryAsync(AvailableCommunityMintFunction availableCommunityMintFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvailableCommunityMintFunction, BigInteger>(availableCommunityMintFunction, blockParameter);
        }

        
        public Task<BigInteger> AvailableCommunityMintQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvailableCommunityMintFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> AvailableDevelopmentMintQueryAsync(AvailableDevelopmentMintFunction availableDevelopmentMintFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvailableDevelopmentMintFunction, BigInteger>(availableDevelopmentMintFunction, blockParameter);
        }

        
        public Task<BigInteger> AvailableDevelopmentMintQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvailableDevelopmentMintFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> AvailableTeamMintQueryAsync(AvailableTeamMintFunction availableTeamMintFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvailableTeamMintFunction, BigInteger>(availableTeamMintFunction, blockParameter);
        }

        
        public Task<BigInteger> AvailableTeamMintQueryAsync(BigInteger index, BlockParameter blockParameter = null)
        {
            var availableTeamMintFunction = new AvailableTeamMintFunction();
                availableTeamMintFunction.Index = index;
            
            return ContractHandler.QueryAsync<AvailableTeamMintFunction, BigInteger>(availableTeamMintFunction, blockParameter);
        }

        public Task<BigInteger> AvaliableDaoMintQueryAsync(AvaliableDaoMintFunction avaliableDaoMintFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvaliableDaoMintFunction, BigInteger>(avaliableDaoMintFunction, blockParameter);
        }

        
        public Task<BigInteger> AvaliableDaoMintQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AvaliableDaoMintFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> BackerMintRequestAsync(BackerMintFunction backerMintFunction)
        {
             return ContractHandler.SendRequestAsync(backerMintFunction);
        }

        public Task<string> BackerMintRequestAsync()
        {
             return ContractHandler.SendRequestAsync<BackerMintFunction>();
        }

        public Task<TransactionReceipt> BackerMintRequestAndWaitForReceiptAsync(BackerMintFunction backerMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(backerMintFunction, cancellationToken);
        }

        public Task<TransactionReceipt> BackerMintRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<BackerMintFunction>(null, cancellationToken);
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

        public Task<BigInteger> BalanceOfAtQueryAsync(BalanceOfAtFunction balanceOfAtFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfAtFunction, BigInteger>(balanceOfAtFunction, blockParameter);
        }

        
        public Task<BigInteger> BalanceOfAtQueryAsync(string account, BigInteger snapshotId, BlockParameter blockParameter = null)
        {
            var balanceOfAtFunction = new BalanceOfAtFunction();
                balanceOfAtFunction.Account = account;
                balanceOfAtFunction.SnapshotId = snapshotId;
            
            return ContractHandler.QueryAsync<BalanceOfAtFunction, BigInteger>(balanceOfAtFunction, blockParameter);
        }

        public Task<string> BurnRequestAsync(BurnFunction burnFunction)
        {
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BurnFunction burnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnRequestAsync(BigInteger amount)
        {
            var burnFunction = new BurnFunction();
                burnFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var burnFunction = new BurnFunction();
                burnFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnFromRequestAsync(BurnFromFunction burnFromFunction)
        {
             return ContractHandler.SendRequestAsync(burnFromFunction);
        }

        public Task<TransactionReceipt> BurnFromRequestAndWaitForReceiptAsync(BurnFromFunction burnFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFromFunction, cancellationToken);
        }

        public Task<string> BurnFromRequestAsync(string account, BigInteger amount)
        {
            var burnFromFunction = new BurnFromFunction();
                burnFromFunction.Account = account;
                burnFromFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(burnFromFunction);
        }

        public Task<TransactionReceipt> BurnFromRequestAndWaitForReceiptAsync(string account, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var burnFromFunction = new BurnFromFunction();
                burnFromFunction.Account = account;
                burnFromFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFromFunction, cancellationToken);
        }

        public Task<BigInteger> ClaimedAllowanceQueryAsync(ClaimedAllowanceFunction claimedAllowanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClaimedAllowanceFunction, BigInteger>(claimedAllowanceFunction, blockParameter);
        }

        
        public Task<BigInteger> ClaimedAllowanceQueryAsync(string returnValue1, BlockParameter blockParameter = null)
        {
            var claimedAllowanceFunction = new ClaimedAllowanceFunction();
                claimedAllowanceFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<ClaimedAllowanceFunction, BigInteger>(claimedAllowanceFunction, blockParameter);
        }

        public Task<string> ClanMintRequestAsync(ClanMintFunction clanMintFunction)
        {
             return ContractHandler.SendRequestAsync(clanMintFunction);
        }

        public Task<string> ClanMintRequestAsync()
        {
             return ContractHandler.SendRequestAsync<ClanMintFunction>();
        }

        public Task<TransactionReceipt> ClanMintRequestAndWaitForReceiptAsync(ClanMintFunction clanMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(clanMintFunction, cancellationToken);
        }

        public Task<TransactionReceipt> ClanMintRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<ClanMintFunction>(null, cancellationToken);
        }

        public Task<string> CommunityMintRequestAsync(CommunityMintFunction communityMintFunction)
        {
             return ContractHandler.SendRequestAsync(communityMintFunction);
        }

        public Task<TransactionReceipt> CommunityMintRequestAndWaitForReceiptAsync(CommunityMintFunction communityMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(communityMintFunction, cancellationToken);
        }

        public Task<string> CommunityMintRequestAsync(BigInteger amount)
        {
            var communityMintFunction = new CommunityMintFunction();
                communityMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(communityMintFunction);
        }

        public Task<TransactionReceipt> CommunityMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var communityMintFunction = new CommunityMintFunction();
                communityMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(communityMintFunction, cancellationToken);
        }

        public Task<BigInteger> CommunityTGEreleaseQueryAsync(CommunityTGEreleaseFunction communityTGEreleaseFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CommunityTGEreleaseFunction, BigInteger>(communityTGEreleaseFunction, blockParameter);
        }

        
        public Task<BigInteger> CommunityTGEreleaseQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CommunityTGEreleaseFunction, BigInteger>(null, blockParameter);
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

        public Task<BigInteger> CurrentTotalMintPerSecQueryAsync(CurrentTotalMintPerSecFunction currentTotalMintPerSecFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CurrentTotalMintPerSecFunction, BigInteger>(currentTotalMintPerSecFunction, blockParameter);
        }

        
        public Task<BigInteger> CurrentTotalMintPerSecQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CurrentTotalMintPerSecFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> DaoMintRequestAsync(DaoMintFunction daoMintFunction)
        {
             return ContractHandler.SendRequestAsync(daoMintFunction);
        }

        public Task<TransactionReceipt> DaoMintRequestAndWaitForReceiptAsync(DaoMintFunction daoMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(daoMintFunction, cancellationToken);
        }

        public Task<string> DaoMintRequestAsync(BigInteger amount)
        {
            var daoMintFunction = new DaoMintFunction();
                daoMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(daoMintFunction);
        }

        public Task<TransactionReceipt> DaoMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var daoMintFunction = new DaoMintFunction();
                daoMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(daoMintFunction, cancellationToken);
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

        public Task<BigInteger> DeploymentTimeQueryAsync(DeploymentTimeFunction deploymentTimeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DeploymentTimeFunction, BigInteger>(deploymentTimeFunction, blockParameter);
        }

        
        public Task<BigInteger> DeploymentTimeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DeploymentTimeFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> DevelopmentMintRequestAsync(DevelopmentMintFunction developmentMintFunction)
        {
             return ContractHandler.SendRequestAsync(developmentMintFunction);
        }

        public Task<TransactionReceipt> DevelopmentMintRequestAndWaitForReceiptAsync(DevelopmentMintFunction developmentMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(developmentMintFunction, cancellationToken);
        }

        public Task<string> DevelopmentMintRequestAsync(BigInteger amount)
        {
            var developmentMintFunction = new DevelopmentMintFunction();
                developmentMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(developmentMintFunction);
        }

        public Task<TransactionReceipt> DevelopmentMintRequestAndWaitForReceiptAsync(BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var developmentMintFunction = new DevelopmentMintFunction();
                developmentMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(developmentMintFunction, cancellationToken);
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

        public Task<string> ExecuteMintPerSecondProposalRequestAsync(ExecuteMintPerSecondProposalFunction executeMintPerSecondProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeMintPerSecondProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMintPerSecondProposalRequestAndWaitForReceiptAsync(ExecuteMintPerSecondProposalFunction executeMintPerSecondProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMintPerSecondProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMintPerSecondProposalRequestAsync(BigInteger proposalID)
        {
            var executeMintPerSecondProposalFunction = new ExecuteMintPerSecondProposalFunction();
                executeMintPerSecondProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeMintPerSecondProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMintPerSecondProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeMintPerSecondProposalFunction = new ExecuteMintPerSecondProposalFunction();
                executeMintPerSecondProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMintPerSecondProposalFunction, cancellationToken);
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

        public Task<BigInteger> MintPerSecondQueryAsync(MintPerSecondFunction mintPerSecondFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MintPerSecondFunction, BigInteger>(mintPerSecondFunction, blockParameter);
        }

        
        public Task<BigInteger> MintPerSecondQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var mintPerSecondFunction = new MintPerSecondFunction();
                mintPerSecondFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<MintPerSecondFunction, BigInteger>(mintPerSecondFunction, blockParameter);
        }

        public Task<string> NameQueryAsync(NameFunction nameFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(nameFunction, blockParameter);
        }

        
        public Task<string> NameQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> OneYearLaterQueryAsync(OneYearLaterFunction oneYearLaterFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OneYearLaterFunction, BigInteger>(oneYearLaterFunction, blockParameter);
        }

        
        public Task<BigInteger> OneYearLaterQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OneYearLaterFunction, BigInteger>(null, blockParameter);
        }

        public Task<bool> PausedQueryAsync(PausedFunction pausedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PausedFunction, bool>(pausedFunction, blockParameter);
        }

        
        public Task<bool> PausedQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PausedFunction, bool>(null, blockParameter);
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

        public Task<string> ProposeMintPerSecondUpdateRequestAsync(ProposeMintPerSecondUpdateFunction proposeMintPerSecondUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMintPerSecondUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMintPerSecondUpdateRequestAndWaitForReceiptAsync(ProposeMintPerSecondUpdateFunction proposeMintPerSecondUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMintPerSecondUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMintPerSecondUpdateRequestAsync(BigInteger mintIndex, BigInteger newMintPerSecond)
        {
            var proposeMintPerSecondUpdateFunction = new ProposeMintPerSecondUpdateFunction();
                proposeMintPerSecondUpdateFunction.MintIndex = mintIndex;
                proposeMintPerSecondUpdateFunction.NewMintPerSecond = newMintPerSecond;
            
             return ContractHandler.SendRequestAsync(proposeMintPerSecondUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMintPerSecondUpdateRequestAndWaitForReceiptAsync(BigInteger mintIndex, BigInteger newMintPerSecond, CancellationTokenSource cancellationToken = null)
        {
            var proposeMintPerSecondUpdateFunction = new ProposeMintPerSecondUpdateFunction();
                proposeMintPerSecondUpdateFunction.MintIndex = mintIndex;
                proposeMintPerSecondUpdateFunction.NewMintPerSecond = newMintPerSecond;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMintPerSecondUpdateFunction, cancellationToken);
        }

        public Task<string> SnapshotRequestAsync(SnapshotFunction snapshotFunction)
        {
             return ContractHandler.SendRequestAsync(snapshotFunction);
        }

        public Task<string> SnapshotRequestAsync()
        {
             return ContractHandler.SendRequestAsync<SnapshotFunction>();
        }

        public Task<TransactionReceipt> SnapshotRequestAndWaitForReceiptAsync(SnapshotFunction snapshotFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(snapshotFunction, cancellationToken);
        }

        public Task<TransactionReceipt> SnapshotRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<SnapshotFunction>(null, cancellationToken);
        }

        public Task<string> StakingMintRequestAsync(StakingMintFunction stakingMintFunction)
        {
             return ContractHandler.SendRequestAsync(stakingMintFunction);
        }

        public Task<string> StakingMintRequestAsync()
        {
             return ContractHandler.SendRequestAsync<StakingMintFunction>();
        }

        public Task<TransactionReceipt> StakingMintRequestAndWaitForReceiptAsync(StakingMintFunction stakingMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(stakingMintFunction, cancellationToken);
        }

        public Task<TransactionReceipt> StakingMintRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<StakingMintFunction>(null, cancellationToken);
        }

        public Task<string> SymbolQueryAsync(SymbolFunction symbolFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(symbolFunction, blockParameter);
        }

        
        public Task<string> SymbolQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> TeamAndTestnetCapQueryAsync(TeamAndTestnetCapFunction teamAndTestnetCapFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TeamAndTestnetCapFunction, BigInteger>(teamAndTestnetCapFunction, blockParameter);
        }

        
        public Task<BigInteger> TeamAndTestnetCapQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TeamAndTestnetCapFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> TeamMintRequestAsync(TeamMintFunction teamMintFunction)
        {
             return ContractHandler.SendRequestAsync(teamMintFunction);
        }

        public Task<TransactionReceipt> TeamMintRequestAndWaitForReceiptAsync(TeamMintFunction teamMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(teamMintFunction, cancellationToken);
        }

        public Task<string> TeamMintRequestAsync(BigInteger index, BigInteger amount)
        {
            var teamMintFunction = new TeamMintFunction();
                teamMintFunction.Index = index;
                teamMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAsync(teamMintFunction);
        }

        public Task<TransactionReceipt> TeamMintRequestAndWaitForReceiptAsync(BigInteger index, BigInteger amount, CancellationTokenSource cancellationToken = null)
        {
            var teamMintFunction = new TeamMintFunction();
                teamMintFunction.Index = index;
                teamMintFunction.Amount = amount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(teamMintFunction, cancellationToken);
        }

        public Task<string> TestnetMintRequestAsync(TestnetMintFunction testnetMintFunction)
        {
             return ContractHandler.SendRequestAsync(testnetMintFunction);
        }

        public Task<TransactionReceipt> TestnetMintRequestAndWaitForReceiptAsync(TestnetMintFunction testnetMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(testnetMintFunction, cancellationToken);
        }

        public Task<string> TestnetMintRequestAsync(List<byte[]> merkleProof)
        {
            var testnetMintFunction = new TestnetMintFunction();
                testnetMintFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAsync(testnetMintFunction);
        }

        public Task<TransactionReceipt> TestnetMintRequestAndWaitForReceiptAsync(List<byte[]> merkleProof, CancellationTokenSource cancellationToken = null)
        {
            var testnetMintFunction = new TestnetMintFunction();
                testnetMintFunction.MerkleProof = merkleProof;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(testnetMintFunction, cancellationToken);
        }

        public Task<BigInteger> TestnetMintPerSecondQueryAsync(TestnetMintPerSecondFunction testnetMintPerSecondFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TestnetMintPerSecondFunction, BigInteger>(testnetMintPerSecondFunction, blockParameter);
        }

        
        public Task<BigInteger> TestnetMintPerSecondQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var testnetMintPerSecondFunction = new TestnetMintPerSecondFunction();
                testnetMintPerSecondFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<TestnetMintPerSecondFunction, BigInteger>(testnetMintPerSecondFunction, blockParameter);
        }

        public Task<byte[]> TestnetRootsQueryAsync(TestnetRootsFunction testnetRootsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TestnetRootsFunction, byte[]>(testnetRootsFunction, blockParameter);
        }

        
        public Task<byte[]> TestnetRootsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var testnetRootsFunction = new TestnetRootsFunction();
                testnetRootsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<TestnetRootsFunction, byte[]>(testnetRootsFunction, blockParameter);
        }

        public Task<BigInteger> TestnetTGEreleaseQueryAsync(TestnetTGEreleaseFunction testnetTGEreleaseFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TestnetTGEreleaseFunction, BigInteger>(testnetTGEreleaseFunction, blockParameter);
        }

        
        public Task<BigInteger> TestnetTGEreleaseQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TestnetTGEreleaseFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> TotalMintsQueryAsync(TotalMintsFunction totalMintsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalMintsFunction, BigInteger>(totalMintsFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalMintsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var totalMintsFunction = new TotalMintsFunction();
                totalMintsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<TotalMintsFunction, BigInteger>(totalMintsFunction, blockParameter);
        }

        public Task<BigInteger> TotalSupplyQueryAsync(TotalSupplyFunction totalSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(null, blockParameter);
        }

        public Task<BigInteger> TotalSupplyAtQueryAsync(TotalSupplyAtFunction totalSupplyAtFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyAtFunction, BigInteger>(totalSupplyAtFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyAtQueryAsync(BigInteger snapshotId, BlockParameter blockParameter = null)
        {
            var totalSupplyAtFunction = new TotalSupplyAtFunction();
                totalSupplyAtFunction.SnapshotId = snapshotId;
            
            return ContractHandler.QueryAsync<TotalSupplyAtFunction, BigInteger>(totalSupplyAtFunction, blockParameter);
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

        public Task<BigInteger> TwoYearsLaterQueryAsync(TwoYearsLaterFunction twoYearsLaterFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TwoYearsLaterFunction, BigInteger>(twoYearsLaterFunction, blockParameter);
        }

        
        public Task<BigInteger> TwoYearsLaterQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TwoYearsLaterFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> UpdatePauseStatusRequestAsync(UpdatePauseStatusFunction updatePauseStatusFunction)
        {
             return ContractHandler.SendRequestAsync(updatePauseStatusFunction);
        }

        public Task<TransactionReceipt> UpdatePauseStatusRequestAndWaitForReceiptAsync(UpdatePauseStatusFunction updatePauseStatusFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updatePauseStatusFunction, cancellationToken);
        }

        public Task<string> UpdatePauseStatusRequestAsync(bool pauseToken)
        {
            var updatePauseStatusFunction = new UpdatePauseStatusFunction();
                updatePauseStatusFunction.PauseToken = pauseToken;
            
             return ContractHandler.SendRequestAsync(updatePauseStatusFunction);
        }

        public Task<TransactionReceipt> UpdatePauseStatusRequestAndWaitForReceiptAsync(bool pauseToken, CancellationTokenSource cancellationToken = null)
        {
            var updatePauseStatusFunction = new UpdatePauseStatusFunction();
                updatePauseStatusFunction.PauseToken = pauseToken;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updatePauseStatusFunction, cancellationToken);
        }
    }
}
