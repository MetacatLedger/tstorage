pragma solidity ^0.5.0;

// compile bin-runtime and use '364497e4' as input argument after the bytecode with ./bin/run

contract Static {

    function __STATIC_INIT() internal view {
        assembly {
            if iszero(tload(address, 0x0)) {
                tstore(0x00, 1)
                tstore(0x20, 0)
            }
        }
    }
}

contract MsgReaderWriter is Static {

    uint constant internal TO_MSG = "Here's ur message.";
    uint constant internal RE_MSG = "Thanks, bro.";

	function msgRead() internal view returns (bytes32){
		bytes32 msg;
        assembly {
            msg := tload(address, 0x20)
        }
		return msg;
	}

	function msgRead(uint addr) internal pure returns (bytes32){
		bytes32 msg;
        assembly {
            msg := tload(addr, 0x20)
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

    constructor() public {
        __STATIC_INIT();
    }

    function body() public view {
        bytes32 msg = msgRead(uint160(msg.sender));
		if (msg == TO_MSG) {
			msgWrite(RE_MSG);
		}
    }
}

contract Test is MsgReaderWriter {

	bytes32 msg;

    constructor() public {
        __STATIC_INIT();
    }

    function body() public {
        __STATIC_INIT();

        Deployed dep = new Deployed();
        msgWrite(TO_MSG);
		dep.body();
		msg = msgRead(uint160(address(dep)));
    }
}