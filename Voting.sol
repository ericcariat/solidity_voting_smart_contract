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

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    function getWinner() public view returns (address) {

    }

    /** Add a voter, only possible by the Admin */
    function addVoter(address _address) public onlyOwner {
        listVoter[_address].isRegistered = true;
        listAddress.push(_address);
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


    function nextWorkflow() public onlyOwner {
        /* Are we, at the end of the flow ? */ 
        if ( uint(currentState) >= uint(WorkflowStatus.VotesTallied) )
            /* yes reset to the initial state */
            currentState = WorkflowStatus(uint(0));
        else    
            /* increment to the next state */
            currentState = WorkflowStatus(uint(currentState)+1);
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
}