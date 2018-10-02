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

    function kill() onlyIfOwner private {
        selfdestruct(owner);
    }

    event LogEtherSended(uint _amount);
    event LogEtherConverted(uint _amount);
    event LogRemittanceCreated(address _recipient);
    event LogPuzzleSolved(RemittanceStruct _remittance);
    event LogEtherWithdrawal(uint _amount);

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
        require(remittance.amount > 0);
        require(encrypt(_puzzle, msg.sender) == remittance.puzzle);
        uint amount = remittance.amount;
        delete remittances[msg.sender];
        emit LogPuzzleSolve(remittance);
        emit LogWithdrawal(remittance.owner, msg.sender, remittance.amount);
        msg.sender.transfer(amount);
        return true;
    }

    function createRemittance(address _recipient, bytes32 _password) public payable returns (bool success) {
        require(owner > 0);
        require(_recipient > address(0x0));
        require(_password != bytes32(0));

        RemittanceStruct memory remittance;
        remittance.owner = msg.sender;
        remittance.balance = msg.value;
        remittance.puzzle = _password;

        remittances[_recipient] = remittance;
        return true;
    }


    function encrypt(string _password, address _address) public pure returns (bytes32) {
        bytes32 result = keccak256(abi.encodePacked(_password, _address));
        return result;
    }

}
