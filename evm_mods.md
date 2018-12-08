# EVM modifications

EVM modifications has been done to [solevm](https://github.com/Ohalo-Ltd/solevm), my PoC Solidity implementation of the evm (no gas metering). It should be done to pyevm or some other real evm but this works for me, for now.

There are two relevant branches, `tstore`, and `tstore_compact`, and you check out the one needed for your testing (along with the modified solidity/lll compiler with the same branch name).

The easiest way to use it is to clone the repo, npm install, (optionally) compile typescript, compile the EVM contract through `./bin/compile.js` then run code through `bin/run.js`. It uses the `geth` standalone `evm` to run the solidity evm with the given code and data as input.

To run code, pass in the code first (without 0x in front) then the data.

`./bin/run.js 600160036003600700 01`

The above example would run the code `600060016002600300` with data `01`.

The output is some data from the contract vm, such as the stack and memory. There is also a list of accounts, with storage and balance and such. The address `0x0f572e5295c57F15886F9b263E2f6d2d6c7b5ec6` is used to run the provided code, and `0xcD1722f2947Def4CF144679da39c4C32bDc35681` is used as default caller. There can be modifications if running directly through `adapter.js`, but with `run.js` it is all standardized.

The error codes can be found in `EVMConstants.sol` and `constants.ts`.

### Implementation details

The transient storage is implemented in `EVMTStorage.sol` - a map between `address` and memory (`EVMMemory.sol`), where the `address` is always a left-padded 20 byte Ethereum address. It is passed along to new EVMs in calls. After calls it is simply passed back, although it will be updated to work the way accounts works which is to pass a copy along and only replace it if the call was successful.

This implements all the important features of this imagined transient storage: 

1. Linear memory
2. Exists throughout the entire transaction
3. Accounts can read the transient storage of any account. 
3. Accounts can only write to their own storage.

Gas is a later issue. As of now it's marked as having very low gas cost, but there is no gas metering, and it will not likely be a gas discussion for quite some time so it does not matter.