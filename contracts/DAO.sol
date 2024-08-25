//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract DAO {
    address owner;
    Token public token;
    uint256 public quorum;

   struct Proposal {
        uint256 id;
        string name;
        uint256 amount;
        address payable recipient;
        uint256 votes;
        bool finalized;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event Propose(
        uint256 id,
        uint256 amount,
        address reipient,
        address creator
    );

    event Vote(
        uint256 id,
        address investor
    );

    constructor(Token _token, uint256 _quorum) {
        owner = msg.sender;
        token = _token;
        quorum = _quorum;  
    }

    //Allow contract to receive ether
    receive() external payable {}

    modifier onlyInvestors() {
        require(
            Token(token).balanceOf(msg.sender) > 0, 
            "must be token holder"
            );
            _;
        
    }

    function createProposal(
        string memory _name, 
        uint256 _amount, 
        address payable _recipient
        ) external onlyInvestors{
            require(address(this).balance >= _amount, "Insufficient balance");

            proposalCount++;
            
            Proposal(proposalCount, _name, _amount, _recipient, 0, false);

            proposals[proposalCount] = Proposal(
                proposalCount, 
                _name, 
                _amount, 
                _recipient, 
                0, 
                false);

            emit Propose(proposalCount, _amount, _recipient, msg.sender);
    }

    mapping(address => mapping(uint256 => bool)) public votes;
    
    function vote(uint256 _id) external onlyInvestors {
        //Fetch proposal from mapping by id
        Proposal storage proposal = proposals[_id];

        //Don't let investors vote twice
        require(votes[msg.sender][_id] == false, "Investor has already voted");

        //update votes
        proposal.votes += token.balanceOf(msg.sender);

        //Track that user has voted
        votes[msg.sender][_id] = true;

        //Emit an event
        emit Vote(_id, msg.sender);
        
    }
}
