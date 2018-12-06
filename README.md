# Transient storage suggestions

Docs related to [EIP1153](https://ethereum-magicians.org/t/eip-transient-storage-opcodes/553)

Note **this is not an official part of the EIP**, it is just to refine some ideas that may or may not be incorporated into it.

Three instructions are proposed here. Informally:

```
TLOAD cAddr sAddr
```

`TLOAD` reads the data stored at address `sAddr` in the transient storage of the account with address `cAddr`.

Example: if the account with address `0x00...01` wants to read from its own transient storage at address `0x20`, in LLL that would be `(TSTORE 0x00...01 0x20)`

```
TSTORE sAddr val
```

Stores the 32 byte value `val` at address `sAddr` in the account's own transient storage.


```
TCOPY cAddr sAddr mAddr len
```

Copies `len` bytes of data from the address `sAddr` in the transient storage of account `cAddr` to memory address `mAddr`.

### docs

`lll_mods.md` explains how to download and build a modified LLLC that accepts the new instructions.

`evm_mods.md` explains how to run compiled code in an evm implementation (gas-less) that has implemented these instructions.

`effects_on_evm.md` is a document that touches on other evm concepts like for example calldata and returndata, and how the general purpose transient storage can be leveraged by other instructions.
