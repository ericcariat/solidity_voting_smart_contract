// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.15;

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

    WorkflowStatus currentstate;

    /*  Create a mapping a Voter address link to a Voter struct */
    mapping (address => Voter) listVoter;
    address[] listAddress;
    Proposal[] listProposal;

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

    /** Admin function to reset (or start) a poll */
    function initPoll() public onlyOwner {
        /* set initial state */
        currentstate = WorkflowStatus.RegisteringVoters; 

        /* clear any previous Votes */
        deleteAll(); 

    #if 0    
        for (uint i;i<listVoter.length;i++) {
            /* iterate for each entry */
            address todel = listAddress[i];
            delete listVoter[listAddress[i]];
            listAddress.pop();
        }
    #endif     
    }   

    function startRegister() public onlyOwner {
        /* set state */
        currentstate = WorkflowStatus.ProposalsRegistrationStarted; 
    }

    /* check if a user is registered */
    modifier isRegisterdUser {
        require ( msg.sender == , "vous n'avez pas le droit de proposer";
        _;
    }

    function registerProposal(string _proposal) public isRegisterdUser {
        /* set state */
        listVoter[msg.sender] = 

        listProposal[listProposal.length-1].description = _proposal; 
        listProposal[listProposal.length-1].voteCount = 0; 
        
        currentstate = WorkflowStatus.ProposalsRegistrationStarted; 
    }   

}