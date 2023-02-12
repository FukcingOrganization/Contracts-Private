using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts;
using System.Threading;

namespace Contracts.Contracts.Clan.ContractDefinition
{


    public partial class ClanDeployment : ClanDeploymentBase
    {
        public ClanDeployment() : base(BYTECODE) { }
        public ClanDeployment(string byteCode) : base(byteCode) { }
    }

    public class ClanDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "0x";
        public ClanDeploymentBase() : base(BYTECODE) { }
        public ClanDeploymentBase(string byteCode) : base(byteCode) { }
        [Parameter("address[13]", "_contracts", 1)]
        public virtual List<string> Contracts { get; set; }
    }

    public partial class DEBUG_setContractFunction : DEBUG_setContractFunctionBase { }

    [Function("DEBUG_setContract")]
    public class DEBUG_setContractFunctionBase : FunctionMessage
    {
        [Parameter("address", "_contractAddress", 1)]
        public virtual string ContractAddress { get; set; }
        [Parameter("uint256", "_index", 2)]
        public virtual BigInteger Index { get; set; }
    }

    public partial class DEBUG_setContractsFunction : DEBUG_setContractsFunctionBase { }

    [Function("DEBUG_setContracts")]
    public class DEBUG_setContractsFunctionBase : FunctionMessage
    {
        [Parameter("address[13]", "_contracts", 1)]
        public virtual List<string> Contracts { get; set; }
    }

    public partial class CheckAndUpdateRoundFunction : CheckAndUpdateRoundFunctionBase { }

    [Function("checkAndUpdateRound")]
    public class CheckAndUpdateRoundFunctionBase : FunctionMessage
    {

    }

    public partial class ClanCooldownTimeFunction : ClanCooldownTimeFunctionBase { }

    [Function("clanCooldownTime", "uint256")]
    public class ClanCooldownTimeFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ClanCounterFunction : ClanCounterFunctionBase { }

    [Function("clanCounter", "uint256")]
    public class ClanCounterFunctionBase : FunctionMessage
    {

    }

    public partial class ClansFunction : ClansFunctionBase { }

    [Function("clans", typeof(ClansOutputDTO))]
    public class ClansFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class CollectedTaxesFunction : CollectedTaxesFunctionBase { }

    [Function("collectedTaxes", "uint256")]
    public class CollectedTaxesFunctionBase : FunctionMessage
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
        [Parameter("uint256", "", 2)]
        public virtual BigInteger ReturnValue2 { get; set; }
    }

    public partial class ContractsFunction : ContractsFunctionBase { }

    [Function("contracts", "address")]
    public class ContractsFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class CooldownTimeFunction : CooldownTimeFunctionBase { }

    [Function("cooldownTime", "uint256")]
    public class CooldownTimeFunctionBase : FunctionMessage
    {

    }

    public partial class CreateClanFunction : CreateClanFunctionBase { }

    [Function("createClan")]
    public class CreateClanFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_lordID", 1)]
        public virtual BigInteger LordID { get; set; }
        [Parameter("string", "_clanName", 2)]
        public virtual string ClanName { get; set; }
        [Parameter("string", "_clanDescription", 3)]
        public virtual string ClanDescription { get; set; }
        [Parameter("string", "_clanMotto", 4)]
        public virtual string ClanMotto { get; set; }
        [Parameter("string", "_clanLogoURI", 5)]
        public virtual string ClanLogoURI { get; set; }
    }

    public partial class DeclareClanFunction : DeclareClanFunctionBase { }

    [Function("declareClan")]
    public class DeclareClanFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class DeclaredClanFunction : DeclaredClanFunctionBase { }

    [Function("declaredClan", "uint256")]
    public class DeclaredClanFunctionBase : FunctionMessage
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class DisbandClanFunction : DisbandClanFunctionBase { }

    [Function("disbandClan")]
    public class DisbandClanFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class ExecuteClanPointAdjustmentFunction : ExecuteClanPointAdjustmentFunctionBase { }

    [Function("executeClanPointAdjustment")]
    public class ExecuteClanPointAdjustmentFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class ExecuteContractAddressUpdateProposalFunction : ExecuteContractAddressUpdateProposalFunctionBase { }

    [Function("executeContractAddressUpdateProposal")]
    public class ExecuteContractAddressUpdateProposalFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class ExecuteCooldownTimeUpdateProposalFunction : ExecuteCooldownTimeUpdateProposalFunctionBase { }

    [Function("executeCooldownTimeUpdateProposal")]
    public class ExecuteCooldownTimeUpdateProposalFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class ExecuteFunctionsProposalTypesUpdateProposalFunction : ExecuteFunctionsProposalTypesUpdateProposalFunctionBase { }

    [Function("executeFunctionsProposalTypesUpdateProposal")]
    public class ExecuteFunctionsProposalTypesUpdateProposalFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class ExecuteMaxPointToChangeUpdateProposalFunction : ExecuteMaxPointToChangeUpdateProposalFunctionBase { }

    [Function("executeMaxPointToChangeUpdateProposal")]
    public class ExecuteMaxPointToChangeUpdateProposalFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class ExecuteMinBalanceToPropClanPointUpdateProposalFunction : ExecuteMinBalanceToPropClanPointUpdateProposalFunctionBase { }

    [Function("executeMinBalanceToPropClanPointUpdateProposal")]
    public class ExecuteMinBalanceToPropClanPointUpdateProposalFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_proposalID", 1)]
        public virtual BigInteger ProposalID { get; set; }
    }

    public partial class FunctionsProposalTypesFunction : FunctionsProposalTypesFunctionBase { }

    [Function("functionsProposalTypes", "uint256")]
    public class FunctionsProposalTypesFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class GetClanBalanceFunction : GetClanBalanceFunctionBase { }

    [Function("getClanBalance", "uint256")]
    public class GetClanBalanceFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class GetClanOfFunction : GetClanOfFunctionBase { }

    [Function("getClanOf", "uint256")]
    public class GetClanOfFunctionBase : FunctionMessage
    {
        [Parameter("address", "_address", 1)]
        public virtual string Address { get; set; }
    }

    public partial class GetClanPointsFunction : GetClanPointsFunctionBase { }

    [Function("getClanPoints", typeof(GetClanPointsOutputDTO))]
    public class GetClanPointsFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class GetMemberPointFunction : GetMemberPointFunctionBase { }

    [Function("getMemberPoint", "uint256")]
    public class GetMemberPointFunctionBase : FunctionMessage
    {
        [Parameter("address", "_memberAddress", 1)]
        public virtual string MemberAddress { get; set; }
    }

    public partial class GiveBatchClanPointsFunction : GiveBatchClanPointsFunctionBase { }

    [Function("giveBatchClanPoints")]
    public class GiveBatchClanPointsFunctionBase : FunctionMessage
    {
        [Parameter("uint256[]", "_clanIDs", 1)]
        public virtual List<BigInteger> ClanIDs { get; set; }
        [Parameter("uint256[]", "_points", 2)]
        public virtual List<BigInteger> Points { get; set; }
        [Parameter("bool[]", "_isDecreasing", 3)]
        public virtual List<bool> IsDecreasing { get; set; }
    }

    public partial class GiveBatchMemberPointFunction : GiveBatchMemberPointFunctionBase { }

    [Function("giveBatchMemberPoint")]
    public class GiveBatchMemberPointFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address[]", "_memberAddresses", 2)]
        public virtual List<string> MemberAddresses { get; set; }
        [Parameter("uint256[]", "_points", 3)]
        public virtual List<BigInteger> Points { get; set; }
        [Parameter("bool[]", "_isDecreasing", 4)]
        public virtual List<bool> IsDecreasing { get; set; }
    }

    public partial class GiveClanPointFunction : GiveClanPointFunctionBase { }

    [Function("giveClanPoint")]
    public class GiveClanPointFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("uint256", "_point", 2)]
        public virtual BigInteger Point { get; set; }
        [Parameter("bool", "_isDecreasing", 3)]
        public virtual bool IsDecreasing { get; set; }
    }

    public partial class GiveMemberPointFunction : GiveMemberPointFunctionBase { }

    [Function("giveMemberPoint")]
    public class GiveMemberPointFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_memberAddress", 2)]
        public virtual string MemberAddress { get; set; }
        [Parameter("uint256", "_point", 3)]
        public virtual BigInteger Point { get; set; }
        [Parameter("bool", "_isDecreasing", 4)]
        public virtual bool IsDecreasing { get; set; }
    }

    public partial class IsMemberExecutorFunction : IsMemberExecutorFunctionBase { }

    [Function("isMemberExecutor", "bool")]
    public class IsMemberExecutorFunctionBase : FunctionMessage
    {
        [Parameter("address", "_memberAddress", 1)]
        public virtual string MemberAddress { get; set; }
    }

    public partial class IsMemberModFunction : IsMemberModFunctionBase { }

    [Function("isMemberMod", "bool")]
    public class IsMemberModFunctionBase : FunctionMessage
    {
        [Parameter("address", "_memberAddress", 1)]
        public virtual string MemberAddress { get; set; }
    }

    public partial class MaxPointToChangeFunction : MaxPointToChangeFunctionBase { }

    [Function("maxPointToChange", "uint256")]
    public class MaxPointToChangeFunctionBase : FunctionMessage
    {

    }

    public partial class MemberRewardClaimFunction : MemberRewardClaimFunctionBase { }

    [Function("memberRewardClaim")]
    public class MemberRewardClaimFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("uint256", "_roundNumber", 2)]
        public virtual BigInteger RoundNumber { get; set; }
    }

    public partial class MinBalanceToProposeClanPointChangeFunction : MinBalanceToProposeClanPointChangeFunctionBase { }

    [Function("minBalanceToProposeClanPointChange", "uint256")]
    public class MinBalanceToProposeClanPointChangeFunctionBase : FunctionMessage
    {

    }

    public partial class ProposalsFunction : ProposalsFunctionBase { }

    [Function("proposals", typeof(ProposalsOutputDTO))]
    public class ProposalsFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ProposeClanPointAdjustmentFunction : ProposeClanPointAdjustmentFunctionBase { }

    [Function("proposeClanPointAdjustment")]
    public class ProposeClanPointAdjustmentFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_roundNumber", 1)]
        public virtual BigInteger RoundNumber { get; set; }
        [Parameter("uint256", "_clanID", 2)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("uint256", "_pointToChange", 3)]
        public virtual BigInteger PointToChange { get; set; }
        [Parameter("bool", "_isDecreasing", 4)]
        public virtual bool IsDecreasing { get; set; }
    }

    public partial class ProposeContractAddressUpdateFunction : ProposeContractAddressUpdateFunctionBase { }

    [Function("proposeContractAddressUpdate")]
    public class ProposeContractAddressUpdateFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_contractIndex", 1)]
        public virtual BigInteger ContractIndex { get; set; }
        [Parameter("address", "_newAddress", 2)]
        public virtual string NewAddress { get; set; }
    }

    public partial class ProposeCooldownTimeUpdateFunction : ProposeCooldownTimeUpdateFunctionBase { }

    [Function("proposeCooldownTimeUpdate")]
    public class ProposeCooldownTimeUpdateFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_newCooldownTime", 1)]
        public virtual BigInteger NewCooldownTime { get; set; }
    }

    public partial class ProposeFunctionsProposalTypesUpdateFunction : ProposeFunctionsProposalTypesUpdateFunctionBase { }

    [Function("proposeFunctionsProposalTypesUpdate")]
    public class ProposeFunctionsProposalTypesUpdateFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_functionIndex", 1)]
        public virtual BigInteger FunctionIndex { get; set; }
        [Parameter("uint256", "_newIndex", 2)]
        public virtual BigInteger NewIndex { get; set; }
    }

    public partial class ProposeMaxPointToChangeUpdateFunction : ProposeMaxPointToChangeUpdateFunctionBase { }

    [Function("proposeMaxPointToChangeUpdate")]
    public class ProposeMaxPointToChangeUpdateFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_newMaxPoint", 1)]
        public virtual BigInteger NewMaxPoint { get; set; }
    }

    public partial class ProposeMinBalanceToPropClanPointUpdateFunction : ProposeMinBalanceToPropClanPointUpdateFunctionBase { }

    [Function("proposeMinBalanceToPropClanPointUpdate")]
    public class ProposeMinBalanceToPropClanPointUpdateFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_newAmount", 1)]
        public virtual BigInteger NewAmount { get; set; }
    }

    public partial class RoundNumberFunction : RoundNumberFunctionBase { }

    [Function("roundNumber", "uint256")]
    public class RoundNumberFunctionBase : FunctionMessage
    {

    }

    public partial class RoundsFunction : RoundsFunctionBase { }

    [Function("rounds", typeof(RoundsOutputDTO))]
    public class RoundsFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class SetClanExecutorFunction : SetClanExecutorFunctionBase { }

    [Function("setClanExecutor")]
    public class SetClanExecutorFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_address", 2)]
        public virtual string Address { get; set; }
        [Parameter("bool", "_setAsExecutor", 3)]
        public virtual bool SetAsExecutor { get; set; }
    }

    public partial class SetClanModFunction : SetClanModFunctionBase { }

    [Function("setClanMod")]
    public class SetClanModFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_address", 2)]
        public virtual string Address { get; set; }
        [Parameter("bool", "_setAsMod", 3)]
        public virtual bool SetAsMod { get; set; }
    }

    public partial class SetMemberFunction : SetMemberFunctionBase { }

    [Function("setMember")]
    public class SetMemberFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_address", 2)]
        public virtual string Address { get; set; }
        [Parameter("bool", "_setAsMember", 3)]
        public virtual bool SetAsMember { get; set; }
    }

    public partial class SignalRebellionFunction : SignalRebellionFunctionBase { }

    [Function("signalRebellion")]
    public class SignalRebellionFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class TransferLeadershipFunction : TransferLeadershipFunctionBase { }

    [Function("transferLeadership")]
    public class TransferLeadershipFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_newLeader", 2)]
        public virtual string NewLeader { get; set; }
    }

    public partial class UpdateClanInfoFunction : UpdateClanInfoFunctionBase { }

    [Function("updateClanInfo")]
    public class UpdateClanInfoFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("string", "_newName", 2)]
        public virtual string NewName { get; set; }
        [Parameter("string", "_newDescription", 3)]
        public virtual string NewDescription { get; set; }
        [Parameter("string", "_newMotto", 4)]
        public virtual string NewMotto { get; set; }
        [Parameter("string", "_newLogoURI", 5)]
        public virtual string NewLogoURI { get; set; }
    }

    public partial class UpdatePointAndRoundFunction : UpdatePointAndRoundFunctionBase { }

    [Function("updatePointAndRound")]
    public class UpdatePointAndRoundFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_memberAddress", 2)]
        public virtual string MemberAddress { get; set; }
    }

    public partial class ViewClanInfoFunction : ViewClanInfoFunctionBase { }

    [Function("viewClanInfo", typeof(ViewClanInfoOutputDTO))]
    public class ViewClanInfoFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class ViewClanRewardsFunction : ViewClanRewardsFunctionBase { }

    [Function("viewClanRewards", typeof(ViewClanRewardsOutputDTO))]
    public class ViewClanRewardsFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class ViewClanRewards1Function : ViewClanRewards1FunctionBase { }

    [Function("viewClanRewards", typeof(ViewClanRewards1OutputDTO))]
    public class ViewClanRewards1FunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_roundNumber", 1)]
        public virtual BigInteger RoundNumber { get; set; }
        [Parameter("uint256", "_clanID", 2)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class ViewIsClanClaimedFunction : ViewIsClanClaimedFunctionBase { }

    [Function("viewIsClanClaimed", "bool")]
    public class ViewIsClanClaimedFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_roundNumber", 1)]
        public virtual BigInteger RoundNumber { get; set; }
        [Parameter("uint256", "_clanID", 2)]
        public virtual BigInteger ClanID { get; set; }
    }

    public partial class ViewIsMemberClaimedFunction : ViewIsMemberClaimedFunctionBase { }

    [Function("viewIsMemberClaimed", "bool")]
    public class ViewIsMemberClaimedFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_roundNumber", 1)]
        public virtual BigInteger RoundNumber { get; set; }
        [Parameter("uint256", "_clanID", 2)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("address", "_memberAddress", 3)]
        public virtual string MemberAddress { get; set; }
    }

    public partial class ViewMemberRewardFunction : ViewMemberRewardFunctionBase { }

    [Function("viewMemberReward", "uint256")]
    public class ViewMemberRewardFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "_clanID", 1)]
        public virtual BigInteger ClanID { get; set; }
        [Parameter("uint256", "_roundNumber", 2)]
        public virtual BigInteger RoundNumber { get; set; }
    }







    public partial class ClanCooldownTimeOutputDTO : ClanCooldownTimeOutputDTOBase { }

    [FunctionOutput]
    public class ClanCooldownTimeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ClanCounterOutputDTO : ClanCounterOutputDTOBase { }

    [FunctionOutput]
    public class ClanCounterOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "_value", 1)]
        public virtual BigInteger Value { get; set; }
    }

    public partial class ClansOutputDTO : ClansOutputDTOBase { }

    [FunctionOutput]
    public class ClansOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("tuple", "info", 1)]
        public virtual ClanInfo Info { get; set; }
        [Parameter("uint256", "proposal_ID", 2)]
        public virtual BigInteger Proposal_ID { get; set; }
        [Parameter("uint256", "balance", 3)]
        public virtual BigInteger Balance { get; set; }
        [Parameter("uint256", "maxMemberCount", 4)]
        public virtual BigInteger MaxMemberCount { get; set; }
        [Parameter("tuple", "memberCounter", 5)]
        public virtual Counter MemberCounter { get; set; }
    }

    public partial class CollectedTaxesOutputDTO : CollectedTaxesOutputDTOBase { }

    [FunctionOutput]
    public class CollectedTaxesOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ContractsOutputDTO : ContractsOutputDTOBase { }

    [FunctionOutput]
    public class ContractsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class CooldownTimeOutputDTO : CooldownTimeOutputDTOBase { }

    [FunctionOutput]
    public class CooldownTimeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }





    public partial class DeclaredClanOutputDTO : DeclaredClanOutputDTOBase { }

    [FunctionOutput]
    public class DeclaredClanOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }















    public partial class FunctionsProposalTypesOutputDTO : FunctionsProposalTypesOutputDTOBase { }

    [FunctionOutput]
    public class FunctionsProposalTypesOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class GetClanBalanceOutputDTO : GetClanBalanceOutputDTOBase { }

    [FunctionOutput]
    public class GetClanBalanceOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class GetClanOfOutputDTO : GetClanOfOutputDTOBase { }

    [FunctionOutput]
    public class GetClanOfOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class GetClanPointsOutputDTO : GetClanPointsOutputDTOBase { }

    [FunctionOutput]
    public class GetClanPointsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
        [Parameter("uint256", "", 2)]
        public virtual BigInteger ReturnValue2 { get; set; }
        [Parameter("uint256", "", 3)]
        public virtual BigInteger ReturnValue3 { get; set; }
        [Parameter("address", "", 4)]
        public virtual string ReturnValue4 { get; set; }
        [Parameter("address[]", "", 5)]
        public virtual List<string> ReturnValue5 { get; set; }
        [Parameter("uint256[]", "", 6)]
        public virtual List<BigInteger> ReturnValue6 { get; set; }
        [Parameter("bool[]", "", 7)]
        public virtual List<bool> ReturnValue7 { get; set; }
        [Parameter("bool[]", "", 8)]
        public virtual List<bool> ReturnValue8 { get; set; }
        [Parameter("bool[]", "", 9)]
        public virtual List<bool> ReturnValue9 { get; set; }
    }











    public partial class IsMemberExecutorOutputDTO : IsMemberExecutorOutputDTOBase { }

    [FunctionOutput]
    public class IsMemberExecutorOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class IsMemberModOutputDTO : IsMemberModOutputDTOBase { }

    [FunctionOutput]
    public class IsMemberModOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class MaxPointToChangeOutputDTO : MaxPointToChangeOutputDTOBase { }

    [FunctionOutput]
    public class MaxPointToChangeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }



    public partial class MinBalanceToProposeClanPointChangeOutputDTO : MinBalanceToProposeClanPointChangeOutputDTOBase { }

    [FunctionOutput]
    public class MinBalanceToProposeClanPointChangeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ProposalsOutputDTO : ProposalsOutputDTOBase { }

    [FunctionOutput]
    public class ProposalsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint8", "status", 1)]
        public virtual byte Status { get; set; }
        [Parameter("uint256", "updateCode", 2)]
        public virtual BigInteger UpdateCode { get; set; }
        [Parameter("bool", "isExecuted", 3)]
        public virtual bool IsExecuted { get; set; }
        [Parameter("uint256", "index", 4)]
        public virtual BigInteger Index { get; set; }
        [Parameter("uint256", "newUint", 5)]
        public virtual BigInteger NewUint { get; set; }
        [Parameter("address", "newAddress", 6)]
        public virtual string NewAddress { get; set; }
        [Parameter("bytes32", "newBytes32", 7)]
        public virtual byte[] NewBytes32 { get; set; }
        [Parameter("bool", "newBool", 8)]
        public virtual bool NewBool { get; set; }
    }













    public partial class RoundNumberOutputDTO : RoundNumberOutputDTOBase { }

    [FunctionOutput]
    public class RoundNumberOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class RoundsOutputDTO : RoundsOutputDTOBase { }

    [FunctionOutput]
    public class RoundsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "totalClanPoint", 1)]
        public virtual BigInteger TotalClanPoint { get; set; }
        [Parameter("uint256", "clanRewards", 2)]
        public virtual BigInteger ClanRewards { get; set; }
        [Parameter("uint256", "claimedRewards", 3)]
        public virtual BigInteger ClaimedRewards { get; set; }
    }















    public partial class ViewClanInfoOutputDTO : ViewClanInfoOutputDTOBase { }

    [FunctionOutput]
    public class ViewClanInfoOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
        [Parameter("uint256", "", 2)]
        public virtual BigInteger ReturnValue2 { get; set; }
        [Parameter("uint256", "", 3)]
        public virtual BigInteger ReturnValue3 { get; set; }
        [Parameter("string", "", 4)]
        public virtual string ReturnValue4 { get; set; }
        [Parameter("string", "", 5)]
        public virtual string ReturnValue5 { get; set; }
        [Parameter("string", "", 6)]
        public virtual string ReturnValue6 { get; set; }
        [Parameter("string", "", 7)]
        public virtual string ReturnValue7 { get; set; }
        [Parameter("bool", "", 8)]
        public virtual bool ReturnValue8 { get; set; }
        [Parameter("bool", "", 9)]
        public virtual bool ReturnValue9 { get; set; }
        [Parameter("bool", "", 10)]
        public virtual bool ReturnValue10 { get; set; }
        [Parameter("bool", "", 11)]
        public virtual bool ReturnValue11 { get; set; }
    }

    public partial class ViewClanRewardsOutputDTO : ViewClanRewardsOutputDTOBase { }

    [FunctionOutput]
    public class ViewClanRewardsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
        [Parameter("uint256", "", 2)]
        public virtual BigInteger ReturnValue2 { get; set; }
    }

    public partial class ViewClanRewards1OutputDTO : ViewClanRewards1OutputDTOBase { }

    [FunctionOutput]
    public class ViewClanRewards1OutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
        [Parameter("uint256", "", 2)]
        public virtual BigInteger ReturnValue2 { get; set; }
    }

    public partial class ViewIsClanClaimedOutputDTO : ViewIsClanClaimedOutputDTOBase { }

    [FunctionOutput]
    public class ViewIsClanClaimedOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class ViewIsMemberClaimedOutputDTO : ViewIsMemberClaimedOutputDTOBase { }

    [FunctionOutput]
    public class ViewIsMemberClaimedOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class ViewMemberRewardOutputDTO : ViewMemberRewardOutputDTOBase { }

    [FunctionOutput]
    public class ViewMemberRewardOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }
}
