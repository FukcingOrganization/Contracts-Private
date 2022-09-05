// Psudo code of FuckingDAO (FDAO) contract

// Remove all the transfer methods by overriding them with an empty method or copy past the other methods from the base contract



/*

// Proposal structure
Struct Proposal{
  uint256 ID;
  string description;
  uint256 yayCount;
  uint256 nayCount;
  timeUnit startTime;
  timeUnit lenght;
  mapping (address voter => bool isVoted) isVoted;
}

Counter proposalCounter;

uint256 minBalanceToPropose

mapping (uint256 proposalID => struct Proposal) proposals

// Access Modifiers

// mint new tokens
  // Propose new mint
  // Mint on result


// claim tokens
  // EOA claim
  // Lord claim


// Voting mechanism
// New Proposal method returns the created proposal ID for the caller to track the result
function newProposal (string storage _description, timeUnit storage _lenght) public returns(uint256) {
  require(owner || balances[sender] > minBalanceToPropose, "You don't have enough voting power to propose");

  // create new proposal
  newProposal.ID = proposalCounter;
  proposalCounter.increment;
  newProposal.description = _description;
  newProposal.startTime = now;
  newProposal.lenght = _lenght;

  // Write the proposal to the mapping
  Proposals[newProposal.ID] = newProposal;

  return proposalCounter - 1; // return the current proposal ID
}

function voteForProposal (uint256 _proposalID, bool isApproving) public {
  require(balances[sender] > 0, "You don't have any voting power!");

  Proposal storage proposal = proposals[_proposalID]; 

  require(proposal.isVoted[sender] == false, "You already voted!");
  require(proposal.startTime + proposal.lenght < now, "Proposal time has expired!");

  proposal.isVoted[sender] = true;

  if (isApproving){
    proposal.yayCount += balances[sender];
  }
  else {    
    proposal.nayCount += balances[sender];
  }
}

function descriptionOfProposal (uint256 _proposalID) view public returns(String){
  return proposals[_proposalID].description;
}

function resultOfProposal (uint256 _proposalID) view public returns(bool){
  Proposal proposal = proposals[_proposalID];
  require (proposal.startTime + proposal.lenght > now, "Proposal is still going on!");

  return proposal.yayCounts > proposal.nayCounts;
}


















*/