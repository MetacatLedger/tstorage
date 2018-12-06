pragma solidity ^0.5.0;

// compile bin-runtime and use '364497e4' as input argument after the bytecode with ./bin/run

contract Test {

    function __STATIC_INIT() private view {
        assembly {
            if iszero(tload(address, 0x0)) {
                tstore(0x00, 1)
                tstore(0x20, 0)
            }
        }
    }

    function counterIncrease() private view {
        assembly {
            tstore(0x20, add(tload(address, 0x20), 1))
        }
    }

    function counterGet() private view returns (uint) {
        uint ctr;
        assembly {
            ctr := tload(address, 0x20)
        }
        return ctr;
    }

    constructor() public {
        __STATIC_INIT();
    }

    function body() public view returns (uint) {
        __STATIC_INIT();

        if (counterGet() < 5) {
            counterIncrease();
            this.body();
        }

        return counterGet();
    }
}