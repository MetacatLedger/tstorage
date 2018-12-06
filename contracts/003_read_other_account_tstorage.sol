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

contract Deployed is Static {

    function counterIncrease() private view {
        assembly {
            tstore(0x20, add(tload(address, 0x20), 1))
        }
    }

    constructor() public {
        __STATIC_INIT();
        counterIncrease();
    }

    function increase() public view {
        counterIncrease();
    }
}

contract Test is Static {

    function counterRead(uint cAddress) private view returns (uint) {
        uint ctr;
        assembly {
            ctr := tload(cAddress, 0x20)
        }
        return ctr;
    }

    constructor() public {
        __STATIC_INIT();
    }

    function body() public returns (uint) {
        __STATIC_INIT();

        Deployed dep = new Deployed();
        dep.increase();
        return counterRead(uint160(address(dep)));
    }
}