pragma solidity ^0.4.24;

contract Remittance {

    address public owner;
    uint deadline = block.number + 1000;

    modifier onlyIfValidEther {
        require(msg.value > 0);
        _;
    }

    modifier onlyIfOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyIfDeadline {
        require(deadline <= now);
        _;
    }

    function kill() onlyIfOwner public {
        selfdestruct(owner);
    }

    function() public { 
        revert();
    }

    event LogRemittanceCreated(address _recipient);
    event LogPuzzleSolvedWithEtherWithdrawed(address _remittance, uint _amount);

    struct RemittanceStruct {
        uint balance;
        address owner;
        bytes32 puzzle;
    }

    constructor() public payable {
        owner = msg.sender;
    }
    
    mapping(address => RemittanceStruct) public remittances;

    function solvePuzzle(string _puzzle) public returns (bool success) {
        RemittanceStruct storage remittance = remittances[msg.sender];
        require(remittance.balance > 0);
        require(encrypt(_puzzle, msg.sender) == remittance.puzzle);
        uint amount = remittance.balance; 
        delete remittances[msg.sender];
        emit LogPuzzleSolvedWithEtherWithdrawed(remittance.owner, amount);
        msg.sender.transfer(amount);
        return true;
    }

    function createRemittance(address _recipient, bytes32 _password) onlyIfValidEther public payable returns (bool success) {
        require(_recipient > 0);
        require(_password != 0);

        require(remittances[_recipient].puzzle == bytes32(0));

        RemittanceStruct memory remittanceStruct;

        remittanceStruct.balance = msg.value;
        remittanceStruct.owner = msg.sender;
        remittanceStruct.puzzle = _password;

        remittances[_recipient] = remittanceStruct;
        emit LogRemittanceCreated(_recipient);
        return true;
    }

    function encrypt(string _password, address _address) public pure returns (bytes32) {
        bytes32 result = keccak256(abi.encodePacked(_password, _address));
        return result;
    }

}
