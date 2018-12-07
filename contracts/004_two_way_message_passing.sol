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
		if (msg == "Here's ur message.") {
			msgWrite(bytes32("Thanks, bro."));
		}
    }
}

contract Test is MsgReaderWriter {

	bytes32 msg;

    constructor() public {
        __STATIC_INIT();
    }

    function body() public returns (uint) {
        __STATIC_INIT();

        Deployed dep = new Deployed();
        msgWrite("Here's ur message.");
		dep.body();
		msg = msgRead(uint160(address(dep)));
    }
}


/*
{

    ;; Contract uses transient storage to pass a message to another contract, then read a response.

	(def "T_INIT_ADDR" 0x00)
	(def "T_MSG_ADDR" 0x20)

	(def "tInit" (TLOAD (ADDRESS) T_INIT_ADDR))
	(def "tMsg" (TLOAD (ADDRESS) T_MSG_ADDR))

	(def "tInitW" (val) (TSTORE T_INIT_ADDR val))
	(def "tMsgW" (val) (TSTORE T_MSG_ADDR val))

	(def "StaticInit" 
	    (unless tInit {
		    (tInitW 0x01)
		    (tMsgW 0x00)
	    })
	)

	StaticInit

	[0x20] (create {
	
		StaticInit

		(returnlll {
			StaticInit
			(when (= (TLOAD (CALLER) T_MSG_ADDR) "Here's ur message.") (tMsgW "Thanks, bro."))
			(return 0)
		})
	})

	(tMsgW "Here's ur message.")
	(msg @0x20 0)
	[[0x00]] (TLOAD @0x20 T_MSG_ADDR)
}
*/