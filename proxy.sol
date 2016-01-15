contract Proxy {
	event Forwarded(address _destination, uint _value);
	event TransferOwnership(address _new_owner);

	address public owner;

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

	function forward_method(address _destination, uint _gas, uint _value, bytes4 _methodName, bytes32[] _transactionData) public returns (uint) {
		/*if (msg.sender == owner) {*/
		    bytes4 method = bytes4(sha3("register(bytes32,address)"));
		    _destination.call.gas(_gas).value(_value)(method, _transactionData);

// 			_destination.call.value(_value)(_methodName, _transactionData);
			/*Forwarded(_destination, _value);*/
			return 1;
		/*}
		return 0;*/
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

var proxyContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"funcSig","outputs":[{"name":"","type":"bytes4"}],"type":"function"},{"constant":false,"inputs":[{"name":"_transactionData","type":"bytes32[]"},{"name":"_destination","type":"address"},{"name":"_gas","type":"uint256"},{"name":"_value","type":"uint256"},{"name":"_methodName","type":"bytes4"}],"name":"forward_method","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"}]);
var proxy = proxyContract.new(
   {
     from: web3.eth.accounts[0],
     data: '60606040525b33600060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908302179055505b6101fb8061003f6000396000f360606040526000357c0100000000000000000000000000000000000000000000000000000000900480638da5cb5b1461004f578063cdb4f17514610088578063f9682bc0146100ab5761004d565b005b61005c6004805050610136565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b610095600480505061015c565b6040518082815260200191505060405180910390f35b6101206004808035906020019082018035906020019191908080602002602001604051908101604052809392919081815260200183836020028082843782019150505050505090909190803590602001909190803590602001909190803590602001909190803590602001909190505061018b565b6040518082815260200191505060405180910390f35b600060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600060149054906101000a90047c01000000000000000000000000000000000000000000000000000000000281565b60006113577c010000000000000000000000000000000000000000000000000000000002600060146101000a81548163ffffffff02191690837c010000000000000000000000000000000000000000000000000000000090040217905550600190506101f2565b9594505050505056',
     gas: 3000000
   }, function(e, contract){
    console.log(e, contract);
    if (typeof contract.address != 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })

pAr='0xbdddc684156a3ead02625ecbccbb7d24b5e43e82'

pcon=proxyContract.at(pAr)
eth.defaultAccount = eth.coinbase
dest='0x5a63738e866969b29989bfb97df6307b1f5602d2'
val = 0
pcon.forward_method.sendTransaction(["te", 5], dest, 1900000, val, 0, {gas:2100000})
pcon.forward_method.call(["te", 5], dest, 1900000, val, 0, {gas:2100000})


Registering on created registry

var abi=[{"name":"register","type":"function","constant":false,"inputs":[{"name":"key","type":"bytes32"},{"name":"addr","type":"address"}],"outputs":[]},{"name":"isRegistered","type":"function","constant":true,"inputs":[{"name":"name","type":"bytes32"}],"outputs":[{"name":"result","type":"bool"}]}];

web3.eth.contract(abi).at('0x5a63738e866969b29989bfb97df6307b1f5602d2').register('0x123', '0x5a63738e866969b29989bfb97df6307b1f5602d2', {gas:2100000})

web3.eth.contract(abi).at('0x5a63738e866969b29989bfb97df6307b1f5602d2').isRegistered().call('test')

working log, register "uitest" with value 13:
eth_sendTransaction [{"from":"0x9fc6fefd7f33ca29ee17f2bfec944695e5f29caf","value":"0x0","gas":"0x2dc6c0","to":"0x5a63738e866969b29989bfb97df6307b1f5602d2","data":"0xd22057a97569746573740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d"}]


*/
