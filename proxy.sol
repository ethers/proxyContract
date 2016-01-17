contract Proxy {
	event Forwarded(address _destination, uint _value);
	event TransferOwnership(address _new_owner);

	address public owner;
	bytes public callData;

	function Proxy() {
		owner = msg.sender;
	}

	function transfer_ownership(address _new_owner) public {
		if (msg.sender == address(this) || msg.sender == owner) {
			owner = _new_owner;
			TransferOwnership(_new_owner);
		}
	}

	function forward(address _destination, uint _value, bytes _transactionBytecode) public {
		if (msg.sender == owner) {
			_destination.call.value(_value)(_transactionBytecode);
			Forwarded(_destination, _value);
		}
	}

/*
	function forward_method(bytes32[] _transactionData, address _destination, uint _value, bytes4 _methodName) public returns (uint) {
		if (msg.sender == owner) {
		    bytes4 method = bytes4(sha3("register(bytes32,address)"));
		    _destination.call.value(_value)(method, _transactionData);

// 			_destination.call.value(_value)(_methodName, _transactionData);
			Forwarded(_destination, _value);
			return 1;
		}
		return 0;
	}
*/


	function register(bytes32 _key, address _addr, address _destination, uint _value, bytes4 _methodName) public returns (uint) {
        bytes4 method = bytes4(sha3("register(bytes32,address)"));

        bytes memory keyBytes = b32ToBytes(_key);
        bytes memory addrBytes = b32ToBytes(bytes32(_addr));

        uint8 i;
        for (i = 0; i < 32; i++) {
            callData[i] = keyBytes[i];
        }

        for (i = 32; i < 64; i++) {
            callData[i] = addrBytes[i];
        }

        _destination.call.value(_value)(method, callData);

		return 1;
	}

	function unregister(bytes32 _key, address _destination, uint _value, bytes4 _methodName) public returns (uint) {
        bytes4 method = bytes4(sha3("unregister(bytes32)"));
        _destination.call.value(_value)(method, _key);
		return 1;
	}

	// this and other helper functions are
	// from https://github.com/iudex/iudex/blob/master/contracts/accountProviderBase.sol
    function b32ToBytes(bytes32 input) internal returns (bytes) {
        uint tmp = uint(input);

        string memory holder = new string(64);
        bytes memory ret = bytes(holder);

        // NOTE: this is written in an expensive way, as out-of-order array access
        //       is not supported yet, e.g. we cannot go in reverse easily
        //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)
        uint j = 0;
        for (uint i = 0; i < 32; i++) {
          uint _tmp = tmp / (2 ** (8*(31-i))); // shr(tmp, 8*(19-i))
          uint nb1 = (_tmp / 0x10) & 0x0f;     // shr(tmp, 8) & 0x0f
          uint nb2 = _tmp & 0x0f;
          ret[j++] = byte(nibbleToChar(nb1));
          ret[j++] = byte(nibbleToChar(nb2));
        }

        return ret;
    }

    function nibbleToChar(uint nibble) internal returns (uint ret) {
        if (nibble > 9)
          return nibble + 87; // nibble + 'a'- 10
        else
          return nibble + 48; // '0'
    }
}

contract SimpleRegistry {
    mapping (bytes32 => address) registry;

    function register(bytes32 key, address value) {
        registry[key] = value;
    }

    function lookup(bytes32 key) returns (address) {
        return registry[key];
    }
}

// args for Solidity browser
// "0x692a70d2e424a56d2c6c27aa97d1a86395877b3a", 0, 0, ["0xcde", "0x1234567890123456789012345678901234567890"]

// https://chriseth.github.io/browser-solidity/?gist=e6d8e79383f4ba57cbcb


/*

var proxyContract = web3.eth.contract([{"constant":false,"inputs":[{"name":"_transactionData","type":"bytes32[]"},{"name":"_destination","type":"address"},{"name":"_value","type":"uint256"},{"name":"_methodName","type":"bytes4"}],"name":"forward_method","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_destination","type":"address"},{"name":"_value","type":"uint256"},{"name":"_transactionBytecode","type":"bytes"}],"name":"forward","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_new_owner","type":"address"}],"name":"transfer_ownership","outputs":[],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_destination","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Forwarded","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_new_owner","type":"address"}],"name":"TransferOwnership","type":"event"}]);
var proxy = proxyContract.new(
   {
     from: web3.eth.accounts[0],
     data: '60606040525b33600060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908302179055505b61050d8061003f6000396000f360606040526000357c01000000000000000000000000000000000000000000000000000000009004806314df20591461005a5780638da5cb5b146100dc578063d7f31eb914610115578063f0350c041461017d57610058565b005b6100c6600480803590602001908201803590602001919190808060200260200160405190810160405280939291908181526020018383602002808284378201915050505050509090919080359060200190919080359060200190919080359060200190919050506103f6565b6040518082815260200191505060405180910390f35b6100e96004805050610195565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b61017b6004808035906020019091908035906020019091908035906020019082018035906020019191908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509090919050506102c4565b005b61019360048080359060200190919050506101bb565b005b600060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b3073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614806102425750600060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16145b156102c05780600060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908302179055507fcfaaa26691e16e66e73290fc725eee1a6b4e0e693a1640484937aac25ffb55a481604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390a15b5b50565b600060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614156103f0578273ffffffffffffffffffffffffffffffffffffffff168282604051808280519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156103805780820380516001836020036101000a031916815260200191505b5091505060006040518083038185876185025a03f192505050507f6f1deddfc28100c291fae8f1064e4a91e844f0841993bb8fba9a913c3b801d808383604051808373ffffffffffffffffffffffffffffffffffffffff1681526020018281526020019250505060405180910390a15b5b505050565b6000600060405180807f726567697374657228627974657333322c616464726573732900000000000000815260200150601901905060405180910390207c01000000000000000000000000000000000000000000000000000000008091040290508473ffffffffffffffffffffffffffffffffffffffff1684827c010000000000000000000000000000000000000000000000000000000090049088604051837c0100000000000000000000000000000000000000000000000000000000028152600401808280519060200190602002808383829060006004602084601f0104600f02600301f15090500191505060006040518083038185886185025a03f193505050505060019150610504565b5094935050505056',
     gas: 3000000
   }, function(e, contract){
    console.log(e, contract);
    if (typeof contract.address != 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })

pAr=''

pcon=proxyContract.at(pAr)
eth.defaultAccount = eth.coinbase
dest='0x5a63738e866969b29989bfb97df6307b1f5602d2'
val = 0

pcon.register.call("te", 5, dest, val, 0, {gas:2100000})

pcon.forward_method.sendTransaction(["te", 5], dest, val, 0, {gas:2100000})
pcon.forward_method.call(["te", 5], dest, val, 0, {gas:2100000})

For unregister:
pcon.forward_method.call(["te"], dest, val, 0, {gas:2100000})



Registering on created registry

var abi=[{"name":"unregister","type":"function","constant":false,"inputs":[{"name":"key","type":"bytes32"}],"outputs":[]},{"name":"register","type":"function","constant":false,"inputs":[{"name":"key","type":"bytes32"},{"name":"addr","type":"address"}],"outputs":[]},{"name":"isRegistered","type":"function","constant":true,"inputs":[{"name":"name","type":"bytes32"}],"outputs":[{"name":"result","type":"bool"}]}];
web3.eth.contract(abi).at('0x5a63738e866969b29989bfb97df6307b1f5602d2').register('0x123', '0x5a63738e866969b29989bfb97df6307b1f5602d2', {gas:2100000})

web3.eth.contract(abi).at('0x5a63738e866969b29989bfb97df6307b1f5602d2').isRegistered().call('test')

working log, register "uitest" with value 13:
eth_sendTransaction [{"from":"0x9fc6fefd7f33ca29ee17f2bfec944695e5f29caf","value":"0x0","gas":"0x2dc6c0","to":"0x5a63738e866969b29989bfb97df6307b1f5602d2","data":"0xd22057a97569746573740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d"}]


*/
