var json = require("../build/contracts/StoreMap.json");
var contract = require("truffle-contract");
var MyContract = contract(json);

// Step 3: Provision the contract with a web3 provider
MyContract.setProvider(new Web3.providers.HttpProvider("http://localhost:8545"));

// Step 4: Use the contract!
MyContract.deployed().then(function(deployed) {
  return deployed.get_map.call(1);
});

