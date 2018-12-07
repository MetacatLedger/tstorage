pragma solidity ^0.5.0;

// compile bin-runtime and use '364497e4' as input argument after the bytecode with ./bin/run

contract MsgReaderWriter {

    bytes32 constant internal TO_MSG = "Here's ur message.";
    bytes32 constant internal RE_MSG = "Thanks, bro.";

	function msgRead() internal view returns (bytes32){
		bytes32 msg;
        assembly {
            msg := tload(0x20)
        }
		return msg;
	}

	function msgWrite(bytes32 val) internal pure {
        assembly {
            tstore(0x20, val)
        }
	}

}

contract Deployed is MsgReaderWriter {

    function body() public view {
        bytes32 msg = msgRead();
		if (msg == TO_MSG) {
			msgWrite(RE_MSG);
		}
    }
}

contract Test is MsgReaderWriter {

	bytes32 msg;

    constructor() public {
    }

    function body() public {
        Deployed dep = new Deployed();
        msgWrite(TO_MSG);
		dep.body();
		msg = msgRead();
    }
}