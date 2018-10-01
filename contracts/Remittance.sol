pragma solidity ^0.4.24;


contract Remittance {
    uint ownedWeis;
    address owner;

    WalletOwner[2] owners;

    uint deadline = block.number + 1000;

    modifier validEtherSend {
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

    modifier onlyIfBob {
        require(msg.sender == owners[1].owner);
        _;
    }

    function kill() onlyIfOwner private {
        selfdestruct(owner);
    }

    mapping(address => uint) authentications;

    event LogEtherSended(uint _amount);
    event LogEtherConverted(uint _amount);

    struct WalletOwner {
        uint balance;
        address owner;
    }

    constructor(address _bob, address _carol) public payable {
        owner = msg.sender;
        owners[0].balance = 0;
        owners[1].balance = 0;
        owners[0].owner = _bob;
        owners[1].owner = _carol;
    }

    function authenticate(uint authenticationToken) private {
        require(authenticationToken > 0);
        address prover = msg.sender;
        authentications[prover] = authenticationToken;
    }

    function getAuthenticationToken(address prover) private constant returns (uint) {
        return authentications[prover];
    }

    function transferEther(uint _amount) public validEtherSend returns (bool success) {
        require(_amount > 0);
        owners[1].balance += _amount;
        uint authenticator = getAuthenticationToken(msg.sender);
        authenticate(authenticator);
        emit LogEtherSended(_amount);
        return true;
    }

    function convertEther(uint _amount) private validEtherSend view returns (uint convert) {
        uint converted = _amount * 2;
        return converted;
    }

    function claimRefund() public onlyIfDeadline returns (bool success) {
        uint amount = msg.sender.balance;
        owners[1].balance -= amount;
        return true;
    }
}
