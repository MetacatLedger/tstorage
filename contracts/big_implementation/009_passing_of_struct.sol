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

    struct Info {
        address addr;
        bytes32 message;
    }

    bytes32 constant internal TO_MSG = "Here's ur message.";
    bytes32 constant internal RE_MSG = "Thanks, bro.";

	function msgRead(address addr) internal view returns (Info memory) {
		Info memory info;
        assembly {
            mstore(info, tload(addr, 0x20))
            mstore(add(info, 0x20), tload(addr, 0x40))
        }
		return info;
	}

    function msgRead() internal view returns (Info memory) {
        return msgRead(address(this));
    }

	function msgWrite(Info memory info) internal pure {
        assembly {
            tstore(0x20, mload(info))
            tstore(0x40, mload(add(info, 0x20)))
        }
	}

}

contract Deployed is MsgReaderWriter {

    constructor() public {
        __STATIC_INIT();
    }

    function body() public view {
        Info memory info = msgRead(msg.sender);
		if (info.message == TO_MSG) {
			msgWrite(Info(address(this), RE_MSG));
		}
    }
}

contract Test is MsgReaderWriter {

	Info info;

    constructor() public {
        __STATIC_INIT();
    }

    function body() public {
        __STATIC_INIT();

        Deployed dep = new Deployed();
        msgWrite(Info(address(this), TO_MSG));
		dep.body();
		info = msgRead(address(dep));
    }
}
