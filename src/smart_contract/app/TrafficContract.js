trafficContractAbi = [{
    "constant": false,
    "inputs": [
      {
        "internalType": "string",
        "name": "uuid",
        "type": "string"
      }
    ],
    "name": "revalue",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "string",
        "name": "uuid",
        "type": "string"
      }
    ],
    "name": "getQuality",
    "outputs": [
      {
        "internalType": "int256",
        "name": "",
        "type": "int256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "string",
        "name": "uuid",
        "type": "string"
      }
    ],
    "name": "getSinglePos",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "string",
        "name": "uuid",
        "type": "string"
      },
      {
        "internalType": "uint256",
        "name": "time",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_latOri",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_lonOri",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_latFix",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_lonFix",
        "type": "uint256"
      }
    ],
    "name": "setSinglePos",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }];