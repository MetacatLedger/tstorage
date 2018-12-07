pragma solidity ^0.5.0;

// compile bin-runtime and use '364497e4' as input argument after the bytecode with ./bin/run

contract MsgReaderWriter {

    bytes32 constant internal TO_MSG1 = "Here's ur msg.";
    bytes32 constant internal RE_MSG1 = "U want money?";
    bytes32 constant internal TO_MSG2 = "No.";
    bytes32 constant internal RE_MSG2 = "Thanks 4 free msg.";

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

    function body(Test c) public view {
        // Read incoming message.
        bytes32 msg = msgRead();
		if (msg == TO_MSG1) {
            // Write question.
			msgWrite(RE_MSG1);
            // Call back to check.
            c.reply();
            // Check new message and write a reply, concluding this call.
            if (msgRead() == TO_MSG2) {
                msgWrite(RE_MSG2);
            }
		}
    }
}

contract Test is MsgReaderWriter {

	bytes32 msg;

    constructor() public {
    }

    function body() public {
        Deployed dep = new Deployed();
        // Write message
        msgWrite(TO_MSG1);
        // Call. Note solidity will still use calldata for function identifier here,
        // since these are just ordinary functions.
		dep.body(this);
        // write response to storage. Should be RE_MSG2
		msg = msgRead();
    }

    function reply() public view {
        if (msgRead() == RE_MSG1) {
            msgWrite(TO_MSG2);
        }
    }
}