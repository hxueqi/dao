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
}
