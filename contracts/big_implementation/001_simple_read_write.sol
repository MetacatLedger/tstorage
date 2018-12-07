pragma solidity ^0.5.0;

// compile bin-runtime and use '364497e4' as input argument after the bytecode with ./bin/run

contract Test {

    function __STATIC_INIT() private view {
        assembly {
            if iszero(tload(address, 0x0)) {
                tstore(0x00, 1)
            }
        }
    }

    constructor() public {
        __STATIC_INIT();
    }

    function body() public view returns (bool) {
        __STATIC_INIT();

        bool staticInit;
        assembly {
            staticInit := tload(address, 0)
        }
        return staticInit;
    }
}