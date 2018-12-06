Docs related to [EIP1153](https://ethereum-magicians.org/t/eip-transient-storage-opcodes/553)

Note this is not an official part of the EIP, it is just to refine some ideas that may or may not be incorporated into it.

`lll_mods.md` explains how to download and build a modified LLLC that accepts the new instructions.

`evm_mods.md` explains how to run compiled code in an evm implementation (gas-less) that has implemented these instructions.

`effects_on_evm.md` is a document that touches on other evm concepts like for example calldata and returndata, and how the general purpose transient storage can be leveraged by other instructions.
