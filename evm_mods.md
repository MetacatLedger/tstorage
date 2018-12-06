# EVM modifications

EVM modifications has been done to [solevm](https://github.com/Ohalo-Ltd/solevm), my PoC Solidity implementation of the evm (no gas metering). It should be done to pyevm or some other real evm but this works for me, for now.

The easiest way to use it is to clone the repo, npm install, compile typescript then run code through `bin/run.js`. It uses the `geth` standalone `evm` to run the solidity evm with the given code and data as input.

To run code, pass in the code first (without 0x in front) then the data.

`./bin/run.js 600160036003600700 01`

The above example would run the code `600060016002600300` with data `01`.

The output is some data from the contract vm, such as the stack and memory. There is also a list of accounts, with storage and balance and such. The address `0x0f572e5295c57F15886F9b263E2f6d2d6c7b5ec6` is used to run the provided code, and `0xcD1722f2947Def4CF144679da39c4C32bDc35681` is used as default caller. There can be modifications if running directly through `adapter.js`, but with `run.js` it is all standardized.

The error codes can be found in 

### Implementation details

The transient storage implementation (as of right now) uses a storage type map but with evm memories as values rather then just a 32 byte number. Basically gives each account an additional memory which it can read and write to from any running VM instance, and the data will persist over an entire transaction. It can also read from the transient storage of other accounts.