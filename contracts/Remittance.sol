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

    //Function for  
    function kill() onlyIfOwner private {
        selfdestruct(owner);
    }

    //Fallback function
    function() public { 
        revert();
    }

    event LogEtherSended(uint _amount);
    event LogEtherConverted(uint _amount);
    event LogRemittanceCreated(address _recipient);
    event LogPuzzleSolved(address _remittance);
    event LogEtherWithdrawal(uint _amount);
    event LogKilled(address indexed _by);

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
        emit LogPuzzleSolved(remittance.owner);
        emit LogEtherWithdrawal(amount);
        msg.sender.transfer(amount);
        return true;
    }

    function createRemittance(address _recipient, bytes32 _password) public payable returns (bool success) {
        require(owner > 0);
        require(_recipient > address(0x0));
        require(_password != bytes32(0));

        require(remittances[_recipient].puzzle == bytes32(0));

        RemittanceStruct memory remittanceStruct;

        remittanceStruct.balance = msg.value;
        remittanceStruct.owner = msg.sender;
        remittanceStruct.puzzle = _password;

        remittances[_recipient] = remittanceStruct;
        return true;
    }

    function encrypt(string _password, address _address) public pure returns (bytes32) {
        bytes32 result = keccak256(abi.encodePacked(_password, _address));
        return result;
    }

}
