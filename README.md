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

The idea is that the instructions are backed by a mapping, `Map<Address, Memory>`, where `Address` is a regular 20 byte Ethereum address, and `Memory` is some kind of byte array similar to the regular EVM memory (meaning it uses 32 byte words, can be expanded, etc.) 

The map would be initialized when a transaction is run, and various things could be done to it, and then as the program runs, the memory could be accessed through the instructions, e.g. `(TLOAD accountAddress, storageAddress) := tStorage.get(accountAddress).load(storageAddress)`, where `load` is a function that returns the 32 bytes starting at `storageAddress`.

### docs

`lll_mods.md` explains how to download and build a modified LLLC that accepts the new instructions.

`evm_mods.md` explains how to run compiled code in an evm implementation (gas-less) that has implemented these instructions.

`effects_on_evm.md` is a document that touches on other evm concepts like for example calldata and returndata, and how the general purpose transient storage can be leveraged by other instructions.
