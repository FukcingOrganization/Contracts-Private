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
using Contracts.Contracts.Clan.ContractDefinition;

namespace Contracts.Contracts.Clan
{
    public partial class ClanService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ClanDeployment clanDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ClanDeployment>().SendRequestAndWaitForReceiptAsync(clanDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ClanDeployment clanDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ClanDeployment>().SendRequestAsync(clanDeployment);
        }

        public static async Task<ClanService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ClanDeployment clanDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, clanDeployment, cancellationTokenSource);
            return new ClanService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public ClanService(Nethereum.Web3.Web3 web3, string contractAddress)
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

        public Task<string> CheckAndUpdateRoundRequestAsync(CheckAndUpdateRoundFunction checkAndUpdateRoundFunction)
        {
             return ContractHandler.SendRequestAsync(checkAndUpdateRoundFunction);
        }

        public Task<string> CheckAndUpdateRoundRequestAsync()
        {
             return ContractHandler.SendRequestAsync<CheckAndUpdateRoundFunction>();
        }

        public Task<TransactionReceipt> CheckAndUpdateRoundRequestAndWaitForReceiptAsync(CheckAndUpdateRoundFunction checkAndUpdateRoundFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(checkAndUpdateRoundFunction, cancellationToken);
        }

        public Task<TransactionReceipt> CheckAndUpdateRoundRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<CheckAndUpdateRoundFunction>(null, cancellationToken);
        }

        public Task<BigInteger> ClanCooldownTimeQueryAsync(ClanCooldownTimeFunction clanCooldownTimeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClanCooldownTimeFunction, BigInteger>(clanCooldownTimeFunction, blockParameter);
        }

        
        public Task<BigInteger> ClanCooldownTimeQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var clanCooldownTimeFunction = new ClanCooldownTimeFunction();
                clanCooldownTimeFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<ClanCooldownTimeFunction, BigInteger>(clanCooldownTimeFunction, blockParameter);
        }

        public Task<BigInteger> ClanCounterQueryAsync(ClanCounterFunction clanCounterFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClanCounterFunction, BigInteger>(clanCounterFunction, blockParameter);
        }

        
        public Task<BigInteger> ClanCounterQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClanCounterFunction, BigInteger>(null, blockParameter);
        }

        public Task<ClansOutputDTO> ClansQueryAsync(ClansFunction clansFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ClansFunction, ClansOutputDTO>(clansFunction, blockParameter);
        }

        public Task<ClansOutputDTO> ClansQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var clansFunction = new ClansFunction();
                clansFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ClansFunction, ClansOutputDTO>(clansFunction, blockParameter);
        }

        public Task<BigInteger> CollectedTaxesQueryAsync(CollectedTaxesFunction collectedTaxesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CollectedTaxesFunction, BigInteger>(collectedTaxesFunction, blockParameter);
        }

        
        public Task<BigInteger> CollectedTaxesQueryAsync(string returnValue1, BigInteger returnValue2, BlockParameter blockParameter = null)
        {
            var collectedTaxesFunction = new CollectedTaxesFunction();
                collectedTaxesFunction.ReturnValue1 = returnValue1;
                collectedTaxesFunction.ReturnValue2 = returnValue2;
            
            return ContractHandler.QueryAsync<CollectedTaxesFunction, BigInteger>(collectedTaxesFunction, blockParameter);
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

        public Task<BigInteger> CooldownTimeQueryAsync(CooldownTimeFunction cooldownTimeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CooldownTimeFunction, BigInteger>(cooldownTimeFunction, blockParameter);
        }

        
        public Task<BigInteger> CooldownTimeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<CooldownTimeFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> CreateClanRequestAsync(CreateClanFunction createClanFunction)
        {
             return ContractHandler.SendRequestAsync(createClanFunction);
        }

        public Task<TransactionReceipt> CreateClanRequestAndWaitForReceiptAsync(CreateClanFunction createClanFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanFunction, cancellationToken);
        }

        public Task<string> CreateClanRequestAsync(BigInteger lordID, string clanName, string clanDescription, string clanMotto, string clanLogoURI)
        {
            var createClanFunction = new CreateClanFunction();
                createClanFunction.LordID = lordID;
                createClanFunction.ClanName = clanName;
                createClanFunction.ClanDescription = clanDescription;
                createClanFunction.ClanMotto = clanMotto;
                createClanFunction.ClanLogoURI = clanLogoURI;
            
             return ContractHandler.SendRequestAsync(createClanFunction);
        }

        public Task<TransactionReceipt> CreateClanRequestAndWaitForReceiptAsync(BigInteger lordID, string clanName, string clanDescription, string clanMotto, string clanLogoURI, CancellationTokenSource cancellationToken = null)
        {
            var createClanFunction = new CreateClanFunction();
                createClanFunction.LordID = lordID;
                createClanFunction.ClanName = clanName;
                createClanFunction.ClanDescription = clanDescription;
                createClanFunction.ClanMotto = clanMotto;
                createClanFunction.ClanLogoURI = clanLogoURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createClanFunction, cancellationToken);
        }

        public Task<string> DeclareClanRequestAsync(DeclareClanFunction declareClanFunction)
        {
             return ContractHandler.SendRequestAsync(declareClanFunction);
        }

        public Task<TransactionReceipt> DeclareClanRequestAndWaitForReceiptAsync(DeclareClanFunction declareClanFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(declareClanFunction, cancellationToken);
        }

        public Task<string> DeclareClanRequestAsync(BigInteger clanID)
        {
            var declareClanFunction = new DeclareClanFunction();
                declareClanFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAsync(declareClanFunction);
        }

        public Task<TransactionReceipt> DeclareClanRequestAndWaitForReceiptAsync(BigInteger clanID, CancellationTokenSource cancellationToken = null)
        {
            var declareClanFunction = new DeclareClanFunction();
                declareClanFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(declareClanFunction, cancellationToken);
        }

        public Task<BigInteger> DeclaredClanQueryAsync(DeclaredClanFunction declaredClanFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DeclaredClanFunction, BigInteger>(declaredClanFunction, blockParameter);
        }

        
        public Task<BigInteger> DeclaredClanQueryAsync(string returnValue1, BlockParameter blockParameter = null)
        {
            var declaredClanFunction = new DeclaredClanFunction();
                declaredClanFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<DeclaredClanFunction, BigInteger>(declaredClanFunction, blockParameter);
        }

        public Task<string> DisbandClanRequestAsync(DisbandClanFunction disbandClanFunction)
        {
             return ContractHandler.SendRequestAsync(disbandClanFunction);
        }

        public Task<TransactionReceipt> DisbandClanRequestAndWaitForReceiptAsync(DisbandClanFunction disbandClanFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(disbandClanFunction, cancellationToken);
        }

        public Task<string> DisbandClanRequestAsync(BigInteger clanID)
        {
            var disbandClanFunction = new DisbandClanFunction();
                disbandClanFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAsync(disbandClanFunction);
        }

        public Task<TransactionReceipt> DisbandClanRequestAndWaitForReceiptAsync(BigInteger clanID, CancellationTokenSource cancellationToken = null)
        {
            var disbandClanFunction = new DisbandClanFunction();
                disbandClanFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(disbandClanFunction, cancellationToken);
        }

        public Task<string> ExecuteClanPointAdjustmentRequestAsync(ExecuteClanPointAdjustmentFunction executeClanPointAdjustmentFunction)
        {
             return ContractHandler.SendRequestAsync(executeClanPointAdjustmentFunction);
        }

        public Task<TransactionReceipt> ExecuteClanPointAdjustmentRequestAndWaitForReceiptAsync(ExecuteClanPointAdjustmentFunction executeClanPointAdjustmentFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeClanPointAdjustmentFunction, cancellationToken);
        }

        public Task<string> ExecuteClanPointAdjustmentRequestAsync(BigInteger proposalID)
        {
            var executeClanPointAdjustmentFunction = new ExecuteClanPointAdjustmentFunction();
                executeClanPointAdjustmentFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeClanPointAdjustmentFunction);
        }

        public Task<TransactionReceipt> ExecuteClanPointAdjustmentRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeClanPointAdjustmentFunction = new ExecuteClanPointAdjustmentFunction();
                executeClanPointAdjustmentFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeClanPointAdjustmentFunction, cancellationToken);
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

        public Task<string> ExecuteCooldownTimeUpdateProposalRequestAsync(ExecuteCooldownTimeUpdateProposalFunction executeCooldownTimeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeCooldownTimeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteCooldownTimeUpdateProposalRequestAndWaitForReceiptAsync(ExecuteCooldownTimeUpdateProposalFunction executeCooldownTimeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeCooldownTimeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteCooldownTimeUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeCooldownTimeUpdateProposalFunction = new ExecuteCooldownTimeUpdateProposalFunction();
                executeCooldownTimeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeCooldownTimeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteCooldownTimeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeCooldownTimeUpdateProposalFunction = new ExecuteCooldownTimeUpdateProposalFunction();
                executeCooldownTimeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeCooldownTimeUpdateProposalFunction, cancellationToken);
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

        public Task<string> ExecuteMaxPointToChangeUpdateProposalRequestAsync(ExecuteMaxPointToChangeUpdateProposalFunction executeMaxPointToChangeUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeMaxPointToChangeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMaxPointToChangeUpdateProposalRequestAndWaitForReceiptAsync(ExecuteMaxPointToChangeUpdateProposalFunction executeMaxPointToChangeUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMaxPointToChangeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMaxPointToChangeUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeMaxPointToChangeUpdateProposalFunction = new ExecuteMaxPointToChangeUpdateProposalFunction();
                executeMaxPointToChangeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeMaxPointToChangeUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMaxPointToChangeUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeMaxPointToChangeUpdateProposalFunction = new ExecuteMaxPointToChangeUpdateProposalFunction();
                executeMaxPointToChangeUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMaxPointToChangeUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMinBalanceToPropClanPointUpdateProposalRequestAsync(ExecuteMinBalanceToPropClanPointUpdateProposalFunction executeMinBalanceToPropClanPointUpdateProposalFunction)
        {
             return ContractHandler.SendRequestAsync(executeMinBalanceToPropClanPointUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMinBalanceToPropClanPointUpdateProposalRequestAndWaitForReceiptAsync(ExecuteMinBalanceToPropClanPointUpdateProposalFunction executeMinBalanceToPropClanPointUpdateProposalFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMinBalanceToPropClanPointUpdateProposalFunction, cancellationToken);
        }

        public Task<string> ExecuteMinBalanceToPropClanPointUpdateProposalRequestAsync(BigInteger proposalID)
        {
            var executeMinBalanceToPropClanPointUpdateProposalFunction = new ExecuteMinBalanceToPropClanPointUpdateProposalFunction();
                executeMinBalanceToPropClanPointUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAsync(executeMinBalanceToPropClanPointUpdateProposalFunction);
        }

        public Task<TransactionReceipt> ExecuteMinBalanceToPropClanPointUpdateProposalRequestAndWaitForReceiptAsync(BigInteger proposalID, CancellationTokenSource cancellationToken = null)
        {
            var executeMinBalanceToPropClanPointUpdateProposalFunction = new ExecuteMinBalanceToPropClanPointUpdateProposalFunction();
                executeMinBalanceToPropClanPointUpdateProposalFunction.ProposalID = proposalID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(executeMinBalanceToPropClanPointUpdateProposalFunction, cancellationToken);
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

        public Task<BigInteger> GetClanBalanceQueryAsync(GetClanBalanceFunction getClanBalanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetClanBalanceFunction, BigInteger>(getClanBalanceFunction, blockParameter);
        }

        
        public Task<BigInteger> GetClanBalanceQueryAsync(BigInteger clanID, BlockParameter blockParameter = null)
        {
            var getClanBalanceFunction = new GetClanBalanceFunction();
                getClanBalanceFunction.ClanID = clanID;
            
            return ContractHandler.QueryAsync<GetClanBalanceFunction, BigInteger>(getClanBalanceFunction, blockParameter);
        }

        public Task<BigInteger> GetClanOfQueryAsync(GetClanOfFunction getClanOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetClanOfFunction, BigInteger>(getClanOfFunction, blockParameter);
        }

        
        public Task<BigInteger> GetClanOfQueryAsync(string address, BlockParameter blockParameter = null)
        {
            var getClanOfFunction = new GetClanOfFunction();
                getClanOfFunction.Address = address;
            
            return ContractHandler.QueryAsync<GetClanOfFunction, BigInteger>(getClanOfFunction, blockParameter);
        }

        public Task<GetClanPointsOutputDTO> GetClanPointsQueryAsync(GetClanPointsFunction getClanPointsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<GetClanPointsFunction, GetClanPointsOutputDTO>(getClanPointsFunction, blockParameter);
        }

        public Task<GetClanPointsOutputDTO> GetClanPointsQueryAsync(BigInteger clanID, BlockParameter blockParameter = null)
        {
            var getClanPointsFunction = new GetClanPointsFunction();
                getClanPointsFunction.ClanID = clanID;
            
            return ContractHandler.QueryDeserializingToObjectAsync<GetClanPointsFunction, GetClanPointsOutputDTO>(getClanPointsFunction, blockParameter);
        }

        public Task<string> GetMemberPointRequestAsync(GetMemberPointFunction getMemberPointFunction)
        {
             return ContractHandler.SendRequestAsync(getMemberPointFunction);
        }

        public Task<TransactionReceipt> GetMemberPointRequestAndWaitForReceiptAsync(GetMemberPointFunction getMemberPointFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(getMemberPointFunction, cancellationToken);
        }

        public Task<string> GetMemberPointRequestAsync(string memberAddress)
        {
            var getMemberPointFunction = new GetMemberPointFunction();
                getMemberPointFunction.MemberAddress = memberAddress;
            
             return ContractHandler.SendRequestAsync(getMemberPointFunction);
        }

        public Task<TransactionReceipt> GetMemberPointRequestAndWaitForReceiptAsync(string memberAddress, CancellationTokenSource cancellationToken = null)
        {
            var getMemberPointFunction = new GetMemberPointFunction();
                getMemberPointFunction.MemberAddress = memberAddress;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(getMemberPointFunction, cancellationToken);
        }

        public Task<string> GiveBatchClanPointsRequestAsync(GiveBatchClanPointsFunction giveBatchClanPointsFunction)
        {
             return ContractHandler.SendRequestAsync(giveBatchClanPointsFunction);
        }

        public Task<TransactionReceipt> GiveBatchClanPointsRequestAndWaitForReceiptAsync(GiveBatchClanPointsFunction giveBatchClanPointsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveBatchClanPointsFunction, cancellationToken);
        }

        public Task<string> GiveBatchClanPointsRequestAsync(List<BigInteger> clanIDs, List<BigInteger> points, List<bool> isDecreasing)
        {
            var giveBatchClanPointsFunction = new GiveBatchClanPointsFunction();
                giveBatchClanPointsFunction.ClanIDs = clanIDs;
                giveBatchClanPointsFunction.Points = points;
                giveBatchClanPointsFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(giveBatchClanPointsFunction);
        }

        public Task<TransactionReceipt> GiveBatchClanPointsRequestAndWaitForReceiptAsync(List<BigInteger> clanIDs, List<BigInteger> points, List<bool> isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var giveBatchClanPointsFunction = new GiveBatchClanPointsFunction();
                giveBatchClanPointsFunction.ClanIDs = clanIDs;
                giveBatchClanPointsFunction.Points = points;
                giveBatchClanPointsFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveBatchClanPointsFunction, cancellationToken);
        }

        public Task<string> GiveBatchMemberPointRequestAsync(GiveBatchMemberPointFunction giveBatchMemberPointFunction)
        {
             return ContractHandler.SendRequestAsync(giveBatchMemberPointFunction);
        }

        public Task<TransactionReceipt> GiveBatchMemberPointRequestAndWaitForReceiptAsync(GiveBatchMemberPointFunction giveBatchMemberPointFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveBatchMemberPointFunction, cancellationToken);
        }

        public Task<string> GiveBatchMemberPointRequestAsync(BigInteger clanID, List<string> memberAddresses, List<BigInteger> points, List<bool> isDecreasing)
        {
            var giveBatchMemberPointFunction = new GiveBatchMemberPointFunction();
                giveBatchMemberPointFunction.ClanID = clanID;
                giveBatchMemberPointFunction.MemberAddresses = memberAddresses;
                giveBatchMemberPointFunction.Points = points;
                giveBatchMemberPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(giveBatchMemberPointFunction);
        }

        public Task<TransactionReceipt> GiveBatchMemberPointRequestAndWaitForReceiptAsync(BigInteger clanID, List<string> memberAddresses, List<BigInteger> points, List<bool> isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var giveBatchMemberPointFunction = new GiveBatchMemberPointFunction();
                giveBatchMemberPointFunction.ClanID = clanID;
                giveBatchMemberPointFunction.MemberAddresses = memberAddresses;
                giveBatchMemberPointFunction.Points = points;
                giveBatchMemberPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveBatchMemberPointFunction, cancellationToken);
        }

        public Task<string> GiveClanPointRequestAsync(GiveClanPointFunction giveClanPointFunction)
        {
             return ContractHandler.SendRequestAsync(giveClanPointFunction);
        }

        public Task<TransactionReceipt> GiveClanPointRequestAndWaitForReceiptAsync(GiveClanPointFunction giveClanPointFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveClanPointFunction, cancellationToken);
        }

        public Task<string> GiveClanPointRequestAsync(BigInteger clanID, BigInteger point, bool isDecreasing)
        {
            var giveClanPointFunction = new GiveClanPointFunction();
                giveClanPointFunction.ClanID = clanID;
                giveClanPointFunction.Point = point;
                giveClanPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(giveClanPointFunction);
        }

        public Task<TransactionReceipt> GiveClanPointRequestAndWaitForReceiptAsync(BigInteger clanID, BigInteger point, bool isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var giveClanPointFunction = new GiveClanPointFunction();
                giveClanPointFunction.ClanID = clanID;
                giveClanPointFunction.Point = point;
                giveClanPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveClanPointFunction, cancellationToken);
        }

        public Task<string> GiveMemberPointRequestAsync(GiveMemberPointFunction giveMemberPointFunction)
        {
             return ContractHandler.SendRequestAsync(giveMemberPointFunction);
        }

        public Task<TransactionReceipt> GiveMemberPointRequestAndWaitForReceiptAsync(GiveMemberPointFunction giveMemberPointFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveMemberPointFunction, cancellationToken);
        }

        public Task<string> GiveMemberPointRequestAsync(BigInteger clanID, string memberAddress, BigInteger point, bool isDecreasing)
        {
            var giveMemberPointFunction = new GiveMemberPointFunction();
                giveMemberPointFunction.ClanID = clanID;
                giveMemberPointFunction.MemberAddress = memberAddress;
                giveMemberPointFunction.Point = point;
                giveMemberPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(giveMemberPointFunction);
        }

        public Task<TransactionReceipt> GiveMemberPointRequestAndWaitForReceiptAsync(BigInteger clanID, string memberAddress, BigInteger point, bool isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var giveMemberPointFunction = new GiveMemberPointFunction();
                giveMemberPointFunction.ClanID = clanID;
                giveMemberPointFunction.MemberAddress = memberAddress;
                giveMemberPointFunction.Point = point;
                giveMemberPointFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(giveMemberPointFunction, cancellationToken);
        }

        public Task<bool> IsMemberExecutorQueryAsync(IsMemberExecutorFunction isMemberExecutorFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsMemberExecutorFunction, bool>(isMemberExecutorFunction, blockParameter);
        }

        
        public Task<bool> IsMemberExecutorQueryAsync(string memberAddress, BlockParameter blockParameter = null)
        {
            var isMemberExecutorFunction = new IsMemberExecutorFunction();
                isMemberExecutorFunction.MemberAddress = memberAddress;
            
            return ContractHandler.QueryAsync<IsMemberExecutorFunction, bool>(isMemberExecutorFunction, blockParameter);
        }

        public Task<bool> IsMemberModQueryAsync(IsMemberModFunction isMemberModFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsMemberModFunction, bool>(isMemberModFunction, blockParameter);
        }

        
        public Task<bool> IsMemberModQueryAsync(string memberAddress, BlockParameter blockParameter = null)
        {
            var isMemberModFunction = new IsMemberModFunction();
                isMemberModFunction.MemberAddress = memberAddress;
            
            return ContractHandler.QueryAsync<IsMemberModFunction, bool>(isMemberModFunction, blockParameter);
        }

        public Task<BigInteger> MaxPointToChangeQueryAsync(MaxPointToChangeFunction maxPointToChangeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MaxPointToChangeFunction, BigInteger>(maxPointToChangeFunction, blockParameter);
        }

        
        public Task<BigInteger> MaxPointToChangeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MaxPointToChangeFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> MemberRewardClaimRequestAsync(MemberRewardClaimFunction memberRewardClaimFunction)
        {
             return ContractHandler.SendRequestAsync(memberRewardClaimFunction);
        }

        public Task<TransactionReceipt> MemberRewardClaimRequestAndWaitForReceiptAsync(MemberRewardClaimFunction memberRewardClaimFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(memberRewardClaimFunction, cancellationToken);
        }

        public Task<string> MemberRewardClaimRequestAsync(BigInteger clanID, BigInteger roundNumber)
        {
            var memberRewardClaimFunction = new MemberRewardClaimFunction();
                memberRewardClaimFunction.ClanID = clanID;
                memberRewardClaimFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAsync(memberRewardClaimFunction);
        }

        public Task<TransactionReceipt> MemberRewardClaimRequestAndWaitForReceiptAsync(BigInteger clanID, BigInteger roundNumber, CancellationTokenSource cancellationToken = null)
        {
            var memberRewardClaimFunction = new MemberRewardClaimFunction();
                memberRewardClaimFunction.ClanID = clanID;
                memberRewardClaimFunction.RoundNumber = roundNumber;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(memberRewardClaimFunction, cancellationToken);
        }

        public Task<BigInteger> MinBalanceToProposeClanPointChangeQueryAsync(MinBalanceToProposeClanPointChangeFunction minBalanceToProposeClanPointChangeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinBalanceToProposeClanPointChangeFunction, BigInteger>(minBalanceToProposeClanPointChangeFunction, blockParameter);
        }

        
        public Task<BigInteger> MinBalanceToProposeClanPointChangeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinBalanceToProposeClanPointChangeFunction, BigInteger>(null, blockParameter);
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

        public Task<string> ProposeClanPointAdjustmentRequestAsync(ProposeClanPointAdjustmentFunction proposeClanPointAdjustmentFunction)
        {
             return ContractHandler.SendRequestAsync(proposeClanPointAdjustmentFunction);
        }

        public Task<TransactionReceipt> ProposeClanPointAdjustmentRequestAndWaitForReceiptAsync(ProposeClanPointAdjustmentFunction proposeClanPointAdjustmentFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeClanPointAdjustmentFunction, cancellationToken);
        }

        public Task<string> ProposeClanPointAdjustmentRequestAsync(BigInteger roundNumber, BigInteger clanID, BigInteger pointToChange, bool isDecreasing)
        {
            var proposeClanPointAdjustmentFunction = new ProposeClanPointAdjustmentFunction();
                proposeClanPointAdjustmentFunction.RoundNumber = roundNumber;
                proposeClanPointAdjustmentFunction.ClanID = clanID;
                proposeClanPointAdjustmentFunction.PointToChange = pointToChange;
                proposeClanPointAdjustmentFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAsync(proposeClanPointAdjustmentFunction);
        }

        public Task<TransactionReceipt> ProposeClanPointAdjustmentRequestAndWaitForReceiptAsync(BigInteger roundNumber, BigInteger clanID, BigInteger pointToChange, bool isDecreasing, CancellationTokenSource cancellationToken = null)
        {
            var proposeClanPointAdjustmentFunction = new ProposeClanPointAdjustmentFunction();
                proposeClanPointAdjustmentFunction.RoundNumber = roundNumber;
                proposeClanPointAdjustmentFunction.ClanID = clanID;
                proposeClanPointAdjustmentFunction.PointToChange = pointToChange;
                proposeClanPointAdjustmentFunction.IsDecreasing = isDecreasing;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeClanPointAdjustmentFunction, cancellationToken);
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

        public Task<string> ProposeCooldownTimeUpdateRequestAsync(ProposeCooldownTimeUpdateFunction proposeCooldownTimeUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeCooldownTimeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeCooldownTimeUpdateRequestAndWaitForReceiptAsync(ProposeCooldownTimeUpdateFunction proposeCooldownTimeUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeCooldownTimeUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeCooldownTimeUpdateRequestAsync(BigInteger newCooldownTime)
        {
            var proposeCooldownTimeUpdateFunction = new ProposeCooldownTimeUpdateFunction();
                proposeCooldownTimeUpdateFunction.NewCooldownTime = newCooldownTime;
            
             return ContractHandler.SendRequestAsync(proposeCooldownTimeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeCooldownTimeUpdateRequestAndWaitForReceiptAsync(BigInteger newCooldownTime, CancellationTokenSource cancellationToken = null)
        {
            var proposeCooldownTimeUpdateFunction = new ProposeCooldownTimeUpdateFunction();
                proposeCooldownTimeUpdateFunction.NewCooldownTime = newCooldownTime;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeCooldownTimeUpdateFunction, cancellationToken);
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

        public Task<string> ProposeMaxPointToChangeUpdateRequestAsync(ProposeMaxPointToChangeUpdateFunction proposeMaxPointToChangeUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMaxPointToChangeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMaxPointToChangeUpdateRequestAndWaitForReceiptAsync(ProposeMaxPointToChangeUpdateFunction proposeMaxPointToChangeUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMaxPointToChangeUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMaxPointToChangeUpdateRequestAsync(BigInteger newMaxPoint)
        {
            var proposeMaxPointToChangeUpdateFunction = new ProposeMaxPointToChangeUpdateFunction();
                proposeMaxPointToChangeUpdateFunction.NewMaxPoint = newMaxPoint;
            
             return ContractHandler.SendRequestAsync(proposeMaxPointToChangeUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMaxPointToChangeUpdateRequestAndWaitForReceiptAsync(BigInteger newMaxPoint, CancellationTokenSource cancellationToken = null)
        {
            var proposeMaxPointToChangeUpdateFunction = new ProposeMaxPointToChangeUpdateFunction();
                proposeMaxPointToChangeUpdateFunction.NewMaxPoint = newMaxPoint;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMaxPointToChangeUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMinBalanceToPropClanPointUpdateRequestAsync(ProposeMinBalanceToPropClanPointUpdateFunction proposeMinBalanceToPropClanPointUpdateFunction)
        {
             return ContractHandler.SendRequestAsync(proposeMinBalanceToPropClanPointUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMinBalanceToPropClanPointUpdateRequestAndWaitForReceiptAsync(ProposeMinBalanceToPropClanPointUpdateFunction proposeMinBalanceToPropClanPointUpdateFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMinBalanceToPropClanPointUpdateFunction, cancellationToken);
        }

        public Task<string> ProposeMinBalanceToPropClanPointUpdateRequestAsync(BigInteger newAmount)
        {
            var proposeMinBalanceToPropClanPointUpdateFunction = new ProposeMinBalanceToPropClanPointUpdateFunction();
                proposeMinBalanceToPropClanPointUpdateFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAsync(proposeMinBalanceToPropClanPointUpdateFunction);
        }

        public Task<TransactionReceipt> ProposeMinBalanceToPropClanPointUpdateRequestAndWaitForReceiptAsync(BigInteger newAmount, CancellationTokenSource cancellationToken = null)
        {
            var proposeMinBalanceToPropClanPointUpdateFunction = new ProposeMinBalanceToPropClanPointUpdateFunction();
                proposeMinBalanceToPropClanPointUpdateFunction.NewAmount = newAmount;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(proposeMinBalanceToPropClanPointUpdateFunction, cancellationToken);
        }

        public Task<BigInteger> RoundNumberQueryAsync(RoundNumberFunction roundNumberFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundNumberFunction, BigInteger>(roundNumberFunction, blockParameter);
        }

        
        public Task<BigInteger> RoundNumberQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RoundNumberFunction, BigInteger>(null, blockParameter);
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

        public Task<string> SetClanExecutorRequestAsync(SetClanExecutorFunction setClanExecutorFunction)
        {
             return ContractHandler.SendRequestAsync(setClanExecutorFunction);
        }

        public Task<TransactionReceipt> SetClanExecutorRequestAndWaitForReceiptAsync(SetClanExecutorFunction setClanExecutorFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setClanExecutorFunction, cancellationToken);
        }

        public Task<string> SetClanExecutorRequestAsync(BigInteger clanID, string address, bool setAsExecutor)
        {
            var setClanExecutorFunction = new SetClanExecutorFunction();
                setClanExecutorFunction.ClanID = clanID;
                setClanExecutorFunction.Address = address;
                setClanExecutorFunction.SetAsExecutor = setAsExecutor;
            
             return ContractHandler.SendRequestAsync(setClanExecutorFunction);
        }

        public Task<TransactionReceipt> SetClanExecutorRequestAndWaitForReceiptAsync(BigInteger clanID, string address, bool setAsExecutor, CancellationTokenSource cancellationToken = null)
        {
            var setClanExecutorFunction = new SetClanExecutorFunction();
                setClanExecutorFunction.ClanID = clanID;
                setClanExecutorFunction.Address = address;
                setClanExecutorFunction.SetAsExecutor = setAsExecutor;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setClanExecutorFunction, cancellationToken);
        }

        public Task<string> SetClanModRequestAsync(SetClanModFunction setClanModFunction)
        {
             return ContractHandler.SendRequestAsync(setClanModFunction);
        }

        public Task<TransactionReceipt> SetClanModRequestAndWaitForReceiptAsync(SetClanModFunction setClanModFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setClanModFunction, cancellationToken);
        }

        public Task<string> SetClanModRequestAsync(BigInteger clanID, string address, bool setAsMod)
        {
            var setClanModFunction = new SetClanModFunction();
                setClanModFunction.ClanID = clanID;
                setClanModFunction.Address = address;
                setClanModFunction.SetAsMod = setAsMod;
            
             return ContractHandler.SendRequestAsync(setClanModFunction);
        }

        public Task<TransactionReceipt> SetClanModRequestAndWaitForReceiptAsync(BigInteger clanID, string address, bool setAsMod, CancellationTokenSource cancellationToken = null)
        {
            var setClanModFunction = new SetClanModFunction();
                setClanModFunction.ClanID = clanID;
                setClanModFunction.Address = address;
                setClanModFunction.SetAsMod = setAsMod;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setClanModFunction, cancellationToken);
        }

        public Task<string> SetMemberRequestAsync(SetMemberFunction setMemberFunction)
        {
             return ContractHandler.SendRequestAsync(setMemberFunction);
        }

        public Task<TransactionReceipt> SetMemberRequestAndWaitForReceiptAsync(SetMemberFunction setMemberFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setMemberFunction, cancellationToken);
        }

        public Task<string> SetMemberRequestAsync(BigInteger clanID, string address, bool setAsMember)
        {
            var setMemberFunction = new SetMemberFunction();
                setMemberFunction.ClanID = clanID;
                setMemberFunction.Address = address;
                setMemberFunction.SetAsMember = setAsMember;
            
             return ContractHandler.SendRequestAsync(setMemberFunction);
        }

        public Task<TransactionReceipt> SetMemberRequestAndWaitForReceiptAsync(BigInteger clanID, string address, bool setAsMember, CancellationTokenSource cancellationToken = null)
        {
            var setMemberFunction = new SetMemberFunction();
                setMemberFunction.ClanID = clanID;
                setMemberFunction.Address = address;
                setMemberFunction.SetAsMember = setAsMember;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setMemberFunction, cancellationToken);
        }

        public Task<string> SignalRebellionRequestAsync(SignalRebellionFunction signalRebellionFunction)
        {
             return ContractHandler.SendRequestAsync(signalRebellionFunction);
        }

        public Task<TransactionReceipt> SignalRebellionRequestAndWaitForReceiptAsync(SignalRebellionFunction signalRebellionFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(signalRebellionFunction, cancellationToken);
        }

        public Task<string> SignalRebellionRequestAsync(BigInteger clanID)
        {
            var signalRebellionFunction = new SignalRebellionFunction();
                signalRebellionFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAsync(signalRebellionFunction);
        }

        public Task<TransactionReceipt> SignalRebellionRequestAndWaitForReceiptAsync(BigInteger clanID, CancellationTokenSource cancellationToken = null)
        {
            var signalRebellionFunction = new SignalRebellionFunction();
                signalRebellionFunction.ClanID = clanID;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(signalRebellionFunction, cancellationToken);
        }

        public Task<string> TransferLeadershipRequestAsync(TransferLeadershipFunction transferLeadershipFunction)
        {
             return ContractHandler.SendRequestAsync(transferLeadershipFunction);
        }

        public Task<TransactionReceipt> TransferLeadershipRequestAndWaitForReceiptAsync(TransferLeadershipFunction transferLeadershipFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferLeadershipFunction, cancellationToken);
        }

        public Task<string> TransferLeadershipRequestAsync(BigInteger clanID, string newLeader)
        {
            var transferLeadershipFunction = new TransferLeadershipFunction();
                transferLeadershipFunction.ClanID = clanID;
                transferLeadershipFunction.NewLeader = newLeader;
            
             return ContractHandler.SendRequestAsync(transferLeadershipFunction);
        }

        public Task<TransactionReceipt> TransferLeadershipRequestAndWaitForReceiptAsync(BigInteger clanID, string newLeader, CancellationTokenSource cancellationToken = null)
        {
            var transferLeadershipFunction = new TransferLeadershipFunction();
                transferLeadershipFunction.ClanID = clanID;
                transferLeadershipFunction.NewLeader = newLeader;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferLeadershipFunction, cancellationToken);
        }

        public Task<string> UpdateClanInfoRequestAsync(UpdateClanInfoFunction updateClanInfoFunction)
        {
             return ContractHandler.SendRequestAsync(updateClanInfoFunction);
        }

        public Task<TransactionReceipt> UpdateClanInfoRequestAndWaitForReceiptAsync(UpdateClanInfoFunction updateClanInfoFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateClanInfoFunction, cancellationToken);
        }

        public Task<string> UpdateClanInfoRequestAsync(BigInteger clanID, string newName, string newDescription, string newMotto, string newLogoURI)
        {
            var updateClanInfoFunction = new UpdateClanInfoFunction();
                updateClanInfoFunction.ClanID = clanID;
                updateClanInfoFunction.NewName = newName;
                updateClanInfoFunction.NewDescription = newDescription;
                updateClanInfoFunction.NewMotto = newMotto;
                updateClanInfoFunction.NewLogoURI = newLogoURI;
            
             return ContractHandler.SendRequestAsync(updateClanInfoFunction);
        }

        public Task<TransactionReceipt> UpdateClanInfoRequestAndWaitForReceiptAsync(BigInteger clanID, string newName, string newDescription, string newMotto, string newLogoURI, CancellationTokenSource cancellationToken = null)
        {
            var updateClanInfoFunction = new UpdateClanInfoFunction();
                updateClanInfoFunction.ClanID = clanID;
                updateClanInfoFunction.NewName = newName;
                updateClanInfoFunction.NewDescription = newDescription;
                updateClanInfoFunction.NewMotto = newMotto;
                updateClanInfoFunction.NewLogoURI = newLogoURI;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updateClanInfoFunction, cancellationToken);
        }

        public Task<string> UpdatePointAndRoundRequestAsync(UpdatePointAndRoundFunction updatePointAndRoundFunction)
        {
             return ContractHandler.SendRequestAsync(updatePointAndRoundFunction);
        }

        public Task<TransactionReceipt> UpdatePointAndRoundRequestAndWaitForReceiptAsync(UpdatePointAndRoundFunction updatePointAndRoundFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updatePointAndRoundFunction, cancellationToken);
        }

        public Task<string> UpdatePointAndRoundRequestAsync(BigInteger clanID, string memberAddress)
        {
            var updatePointAndRoundFunction = new UpdatePointAndRoundFunction();
                updatePointAndRoundFunction.ClanID = clanID;
                updatePointAndRoundFunction.MemberAddress = memberAddress;
            
             return ContractHandler.SendRequestAsync(updatePointAndRoundFunction);
        }

        public Task<TransactionReceipt> UpdatePointAndRoundRequestAndWaitForReceiptAsync(BigInteger clanID, string memberAddress, CancellationTokenSource cancellationToken = null)
        {
            var updatePointAndRoundFunction = new UpdatePointAndRoundFunction();
                updatePointAndRoundFunction.ClanID = clanID;
                updatePointAndRoundFunction.MemberAddress = memberAddress;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(updatePointAndRoundFunction, cancellationToken);
        }

        public Task<ViewClanInfoOutputDTO> ViewClanInfoQueryAsync(ViewClanInfoFunction viewClanInfoFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanInfoFunction, ViewClanInfoOutputDTO>(viewClanInfoFunction, blockParameter);
        }

        public Task<ViewClanInfoOutputDTO> ViewClanInfoQueryAsync(BigInteger clanID, BlockParameter blockParameter = null)
        {
            var viewClanInfoFunction = new ViewClanInfoFunction();
                viewClanInfoFunction.ClanID = clanID;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanInfoFunction, ViewClanInfoOutputDTO>(viewClanInfoFunction, blockParameter);
        }

        public Task<ViewClanRewardsOutputDTO> ViewClanRewardsQueryAsync(ViewClanRewardsFunction viewClanRewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanRewardsFunction, ViewClanRewardsOutputDTO>(viewClanRewardsFunction, blockParameter);
        }

        public Task<ViewClanRewardsOutputDTO> ViewClanRewardsQueryAsync(BigInteger clanID, BlockParameter blockParameter = null)
        {
            var viewClanRewardsFunction = new ViewClanRewardsFunction();
                viewClanRewardsFunction.ClanID = clanID;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanRewardsFunction, ViewClanRewardsOutputDTO>(viewClanRewardsFunction, blockParameter);
        }

        public Task<ViewClanRewards1OutputDTO> ViewClanRewardsQueryAsync(ViewClanRewards1Function viewClanRewards1Function, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanRewards1Function, ViewClanRewards1OutputDTO>(viewClanRewards1Function, blockParameter);
        }

        public Task<ViewClanRewards1OutputDTO> ViewClanRewardsQueryAsync(BigInteger roundNumber, BigInteger clanID, BlockParameter blockParameter = null)
        {
            var viewClanRewards1Function = new ViewClanRewards1Function();
                viewClanRewards1Function.RoundNumber = roundNumber;
                viewClanRewards1Function.ClanID = clanID;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewClanRewards1Function, ViewClanRewards1OutputDTO>(viewClanRewards1Function, blockParameter);
        }

        public Task<bool> ViewIsClanClaimedQueryAsync(ViewIsClanClaimedFunction viewIsClanClaimedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewIsClanClaimedFunction, bool>(viewIsClanClaimedFunction, blockParameter);
        }

        
        public Task<bool> ViewIsClanClaimedQueryAsync(BigInteger roundNumber, BigInteger clanID, BlockParameter blockParameter = null)
        {
            var viewIsClanClaimedFunction = new ViewIsClanClaimedFunction();
                viewIsClanClaimedFunction.RoundNumber = roundNumber;
                viewIsClanClaimedFunction.ClanID = clanID;
            
            return ContractHandler.QueryAsync<ViewIsClanClaimedFunction, bool>(viewIsClanClaimedFunction, blockParameter);
        }

        public Task<bool> ViewIsMemberClaimedQueryAsync(ViewIsMemberClaimedFunction viewIsMemberClaimedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewIsMemberClaimedFunction, bool>(viewIsMemberClaimedFunction, blockParameter);
        }

        
        public Task<bool> ViewIsMemberClaimedQueryAsync(BigInteger roundNumber, BigInteger clanID, string memberAddress, BlockParameter blockParameter = null)
        {
            var viewIsMemberClaimedFunction = new ViewIsMemberClaimedFunction();
                viewIsMemberClaimedFunction.RoundNumber = roundNumber;
                viewIsMemberClaimedFunction.ClanID = clanID;
                viewIsMemberClaimedFunction.MemberAddress = memberAddress;
            
            return ContractHandler.QueryAsync<ViewIsMemberClaimedFunction, bool>(viewIsMemberClaimedFunction, blockParameter);
        }

        public Task<BigInteger> ViewMemberRewardQueryAsync(ViewMemberRewardFunction viewMemberRewardFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ViewMemberRewardFunction, BigInteger>(viewMemberRewardFunction, blockParameter);
        }

        
        public Task<BigInteger> ViewMemberRewardQueryAsync(BigInteger clanID, BigInteger roundNumber, BlockParameter blockParameter = null)
        {
            var viewMemberRewardFunction = new ViewMemberRewardFunction();
                viewMemberRewardFunction.ClanID = clanID;
                viewMemberRewardFunction.RoundNumber = roundNumber;
            
            return ContractHandler.QueryAsync<ViewMemberRewardFunction, BigInteger>(viewMemberRewardFunction, blockParameter);
        }
    }
}
