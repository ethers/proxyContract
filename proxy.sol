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

	function forward_method(address _destination, uint _value, bytes4 _methodName, bytes32[] _transactionData) public {
		if (msg.sender == owner) {
			_destination.call.value(_value)(_methodName, _transactionData);
			Forwarded(_destination, _value);
		}
	}
}

contract SimpleRegistry {
    mapping (string => address) registry;

    function register(string key, address value) {
        registry[key] = value;
    }

    function lookup(string key) returns (address) {
        return registry[key];
    }
}
