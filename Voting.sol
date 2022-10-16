// SPDX-License-Identifier: GPL-3.0
// Please see styleguide from https://docs.soliditylang.org/en/v0.8.16/style-guide.html
// Usage : 
// 1. Owner : initWorkflow -> RegisteringVoters
// 2. Owner : addVoter with address
// 3. Owner : nextWorkflow -> ProposalsRegistrationStarted
// 4. Voters : addProposal with a string
// 5. Owner : nextWorkflow -> ProposalsRegistrationEnded
// 6. Owner : nextWorkflow -> VotingSessionStarted
// 7. Voters : 
// 8. Owner : nextWorkflow -> VotingSessionEnded
// 9. Owner : getWinner

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title a voting smart-contract
 */
contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public currentState;

    /*  Create a mapping a Voter address link to a Voter struct */
    mapping (address => Voter) public listVoter;
    address[] public listAddress;
    Proposal[] public listProposal;
    string[] public proposalTable;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    /** Add a voter, only possible by the Admin */
    function addVoter(address _address) public onlyOwner {
        require(_address != address(0),"Invalid address !");
        listVoter[_address].isRegistered = true;
        listAddress.push(_address);
        emit VoterRegistered(_address);
    }

    /** Initialize or reset the current workflow 
      * can be call from anywhere 
      */
    function initWorkflow() public onlyOwner {
        /* reset current state */
        currentState = WorkflowStatus.RegisteringVoters;

        /* clear All - start by the proposal list */
        for (uint i; i<listProposal.length;i++) {
            listProposal.pop();
        }

        /* clear the mapping */
        for (uint i; i<listAddress.length;i++) {
            delete listVoter[listAddress[i]];
        }

        /* clear the adress list */
        for (uint i; i<listAddress.length;i++) {
            listAddress.pop();
        }
    }

    /* Just switch to the next state */
    function nextWorkflow() public onlyOwner {
        WorkflowStatus previousState = currentState;

        /* Are we, at the end of the flow ? */ 
        if ( uint(currentState) >= uint(WorkflowStatus.VotesTallied) )
            /* yes reset to the initial state */
            currentState = WorkflowStatus(uint(0));
        else    
            /* increment to the next state */
            currentState = WorkflowStatus(uint(currentState)+1);

        emit WorkflowStatusChange(previousState, currentState);    
    }


    function getWorkflow() public view onlyOwner returns (string memory) {
        if ( currentState == WorkflowStatus.RegisteringVoters)
            return "RegisteringVoters";
        else if ( currentState == WorkflowStatus.ProposalsRegistrationStarted)
            return "ProposalsRegistrationStarted";
        else if ( currentState == WorkflowStatus.ProposalsRegistrationEnded)
            return "ProposalsRegistrationEnded";
        else if ( currentState == WorkflowStatus.VotingSessionStarted)
            return "VotingSessionStarted";
        else if ( currentState == WorkflowStatus.VotingSessionEnded)
            return "VotingSessionEnded";
        else if ( currentState == WorkflowStatus.VotesTallied)
            return "VotesTallied";
        else 
            return "unknown state";
    }

    /* check this is an authorized voter */
    modifier checkVoter() {
        require (listVoter[msg.sender].isRegistered, "You are not allowed to call this function");
        _;
    }

    /* check the current state */
    modifier checkState(WorkflowStatus _state) {
        require (currentState == _state, "You c'ant do that at that state");
        _;
    }

    /* check the proposal number */
    modifier checkValidProposal(uint _proposalNum) {
        require (_proposalNum < listProposal.length, "Invalid proposition number !");
        _;
    }

    /** Function to add a proposal
     *  only for voters and if we are in the Proposal state 
     */
    function addProposal(string memory _proposition) public checkState(WorkflowStatus.ProposalsRegistrationStarted) checkVoter {
        Proposal memory proposal;

        proposal.description = _proposition;
        proposal.voteCount = 0;

        listProposal.push(proposal);
        emit ProposalRegistered(listProposal.length);
    }

    /** Function to get all proposals
     *  only for voters and if we are in the Voting Session started 
     */
    function getProposal() public checkState(WorkflowStatus.VotingSessionStarted) checkVoter returns (string[] memory) {        
        for (uint i; i<listProposal.length;i++) {
            proposalTable.push(listProposal[i].description);
        }

        return proposalTable;
    }

    /** Function to get all proposals
     *  only for voters and if we are in the Voting Session started 
     */
    function getStProposal() public view checkState(WorkflowStatus.VotingSessionStarted) checkVoter returns (Proposal[] memory) {        
        return listProposal;
    }

    /** Function to vote, restricted to 
     * a registered voter 
     * with a valid proposal ID 
     * In a correct state 
     * a voter that has not voted yet !
     */
    function vote(uint proposalNumber) public checkState(WorkflowStatus.VotingSessionStarted) checkVoter checkValidProposal(proposalNumber) {        
        require(listVoter[msg.sender].hasVoted == false, "You've already voted !");
        listProposal[proposalNumber].voteCount++;
        listVoter[msg.sender].hasVoted = true;
        listVoter[msg.sender].votedProposalId = proposalNumber;
        emit Voted (msg.sender, proposalNumber);
    }

    /** Get the vote result
     */
    function getWinner() public view checkState(WorkflowStatus.VotesTallied) onlyOwner returns (uint) { 
        require (listProposal.length>0, "There are no proposal !");

        uint maxCount;
        uint maxCountIdx;
        bool solutionFound = false;

        /* Check wich proposal has the maximum votes - if ex-aequo take the first one in the list */       
        for (uint i; i<listProposal.length;i++) {
            if ( listProposal[i].voteCount > maxCount ) {
                maxCount = listProposal[i].voteCount;
                maxCountIdx = i;
                solutionFound = true;
            }
        }

        /* Check if we've found a solution ? */
        require (solutionFound, "Nobody voted !");

        return maxCountIdx;
    }    
}