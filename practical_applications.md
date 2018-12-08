## Practical applications (big implementation)

This is a list of things that transient storage could be used for.

### Message passing

Contracts could pass messages like examples in `004_two_way_message_passing.lll`, meaning they can send data without using calldata and return data. This could allow contract writers to pass messages between contracts programatically, and also means transient storage could back other already existing instructions like the various call, calldata and return related ones.

### Static variables

Language designers could use transient storage to implement variables that exist throughout an entire transaction, and can be read from and written to by the same contract from any VM. An example can be found in `002_static_counter.lll`.

### Reentrancy checks

It would be possible to add locks to specific variables, functions, or entire contracts, like in the example `007_reentrancy_lock.lll`. There's talk about locks and such but it feels like a "once-per-execution" rule is perhaps the most useful of all - and how many people really intend for their contracts to be used. Solidity could implement this either as having contracts being locked by default, requiring a modifier `contract C reentrant { ... }`, or the other way around.