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

	function forward_method(address _destination, uint _value, bytes4 _methodName, bytes32[] _transactionData) public returns (uint) {
		if (msg.sender == owner) {
		    bytes4 method = bytes4(sha3("register(bytes32,bytes32)"));
		    _destination.call.value(_value)(method, _transactionData);

// 			_destination.call.value(_value)(_methodName, _transactionData);
			Forwarded(_destination, _value);
			return 1;
		}
		return 0;
	}
}

contract SimpleRegistry {
    mapping (bytes32 => bytes32) registry;

    function register(bytes32 key, bytes32 value) {
        registry[key] = value;
    }

    function lookup(bytes32 key) returns (bytes32) {
        return registry[key];
    }
}

// args for Solidity browser
// "0xaddressOfRegistry", 0, 0, ["0xcde", "0x456"]
