Promise = require('bluebird');

const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
const Remittance = artifacts.require("./Remittance.sol");

Promise.promisifyAll(web3.eth,{suffix: "Promise"});

/*
For upcoming tests
const password1 = "password";
const password2 = "password1";
const password3 = "password2";
*/
contract('Remittance', (accounts) => {

    let alice;
    let bob;
    let carol;

    [alice, bob, carol] = accounts;
    let contractInstance;
    before("Checking if smart contract is setup correctly", () => {
        console.log(accounts);
        assert.isAtLeast(accounts.length, 3, "not enough, something is wrong at the beginning...");
 
        console.log("Alice " + alice);
        console.log("Bob " + bob);
        console.log("Carol " + carol);

        contractInstance = Remittance.deployed({from: alice})
        return web3.eth.getBalance(alice)
        .then(_alice => {
            console.log("Alice balance: " + _alice);
        })
    })
    
    it("just checking if before is going good", () => {
        assert.strictEqual(3, 3);
    })

});