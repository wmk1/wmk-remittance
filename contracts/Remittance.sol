pragma solidity ^0.4.24;


contract Remittance {

    address public owner;
    uint public deadline = block.number + 1000;

    event LogRemittanceCreated(address _recipient);
    event LogPuzzleSolvedWithEtherWithdrawed(address _remittance, uint _amount);

    constructor() public {
        owner = msg.sender;
    }

    function() public payable { 
        revert();
    }

    function kill() public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    struct RemittanceStruct {
        uint balance;
        bytes32 puzzle;
    }
    
    mapping(address => RemittanceStruct) public remittances;

    function solvePuzzle(string _puzzle) public returns (bool success) {
        RemittanceStruct storage remittance = remittances[msg.sender];
        require(remittance.balance > 0);
        require(encrypt(_puzzle, msg.sender) == remittance.puzzle);
        uint amount = remittance.balance; 
        delete remittances[msg.sender];
        emit LogPuzzleSolvedWithEtherWithdrawed(remittance, amount);
        msg.sender.transfer(amount);
        return true;
    }

    function createRemittance(address _recipient, bytes32 _password) public payable returns (bool success) {
        require(msg.value > 0);
        require(_recipient > 0);
        require(_password != 0);

        require(remittances[_recipient].puzzle == bytes32(0));

        RemittanceStruct memory remittanceStruct;

        remittanceStruct.balance = msg.value;
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
