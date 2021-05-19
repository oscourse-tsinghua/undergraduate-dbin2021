mapContractAbi = [
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "name": "geo_maps",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "num",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
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
        "internalType": "uint256",
        "name": "gid",
        "type": "uint256"
      }
    ],
    "name": "get_onetype",
    "outputs": [
      {
        "internalType": "int32[]",
        "name": "feature",
        "type": "int32[]"
      },
      {
        "internalType": "bytes32",
        "name": "names",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "highway",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "gtype",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "path",
        "type": "bytes32[]"
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
        "internalType": "bytes32",
        "name": "hash",
        "type": "bytes32"
      }
    ],
    "name": "get_types",
    "outputs": [
      {
        "internalType": "int32[]",
        "name": "feature",
        "type": "int32[]"
      },
      {
        "internalType": "bytes32[]",
        "name": "names",
        "type": "bytes32[]"
      },
      {
        "internalType": "bytes32[]",
        "name": "highways",
        "type": "bytes32[]"
      },
      {
        "internalType": "bytes32[]",
        "name": "gtypes",
        "type": "bytes32[]"
      },
      {
        "internalType": "bytes32[]",
        "name": "path",
        "type": "bytes32[]"
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
        "internalType": "uint256",
        "name": "gid",
        "type": "uint256"
      },
      {
        "internalType": "int32",
        "name": "minzoom",
        "type": "int32"
      },
      {
        "internalType": "bool",
        "name": "oneway",
        "type": "bool"
      },
      {
        "internalType": "bool",
        "name": "building",
        "type": "bool"
      },
      {
        "internalType": "bytes32",
        "name": "highway",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "name",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "gtype",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "path",
        "type": "bytes32[]"
      }
    ],
    "name": "add_onetype",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "hash",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "gid",
        "type": "uint256"
      }
    ],
    "name": "add_area_line",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
];