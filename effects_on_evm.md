# Overview

Some ideas about how generic transient storage could be used by other instructions.

## Big implementation

### Calls using readonly call-, and return-data.

`CALL gas addr value memPos memSize`

`RETURN memAddr memSize`

`tStore(0)` is a byte array with word size 32 (like memory), laid out as such:

`[dataLen, data ...]`

- Position 0x00: position of data
- Position 0x20: length of data

This would be pre-populated by txdata, and used by the EVM for both txdata and returndata.

#### Making a call

`CALL` - writes data from memory to `tStore(0)` and calls.

The receiving contract gets the data from `tStore(0)`. They can either copy all the data to memory, or work with it from tstore directly.

If the receiving contract returns data, `RETURN` will set `dataLen` and data `tStore(0)` to the correct values.

Additionally, the `CALL` and `RETURN` instructions could forcibly clear tstorage before doing anything else.

#### Notes

This would mean changes to the `CALL` and `RETURN` instructions.

`CALLDATA` and `RETURNDATA` would both become "volatile" (as is the case with `RETURNDATA` now), meaning a call made inside the code would invalidate it. There is no expectation that either of them will remain constant throughout the entire vm execution.

With this system, `RETURNDATA` instructions could just point to tstorage instead of the special purpose return data memory. The behavior would not change much from now, since the memory would be cleared before writing (any) new data and returning.

`CALLDATA` could be managed in much the same way, so the calldata instructions could be rewritten to use tstorage instead on the VM level.

Ultimately, both the returndata and calldata instructions could be deprecated, or alternatively the calldata instructions could be pointing to the original tx data, which could be added in to the tx context and remain throughout the entire tx execution. `TXDATALOAD` (and so on) would of course be better, but this would require no change of the actual name.

#### Example of reading calldata

```
assembly {
	let cdLen := tLoad(0, 0)
	
	if lt(cdLen, 4) {
	    revert()
	}
	
	// read function identifier, etc.
}
```

#### Example of reading returndata:

```
assembly {
	let retLen := tLoad(0, 0)
	let x := tLoad(0, 0x20)
	
	if eq(x, 55) {
	    // ...
	}
	
	// ...
}
```

### Using tStore in code

The `static` flag, or `transient`, or some other keyword, could be used to declare fields that are bound to the contract (account) over the span of an entire transaction rather then the instance of the currently running VM. `transient` may be preferable as `static` could have implications.

A type of "static initialization" could be done using a reserved field.

```
assembly {
    if(iszero(tload(0x80)) {
        tstore(0x80, 1)
        // other init logic
        // ...
    }
}
```


```
{ // start of body code
    
    transient uint x = 5;
    transient bytes bts;
    transient bool b;

    // tStorage
    // 0x0 : static initialization
    // 0x20: free mem pointer
    
    // assembly version of what would always run when contract is called, before any functions.
    if(iszero(tload(address, 0)) { // is tStorage of this contract 0 at address 0x00 
        tstore(0x00, 0x01) // set init flag
        tstore(0x40, 0x05) // init x
        // 0x60 reference to 'bts'
        // 0x80 value of b
        tstore(0x20, 0x100) // update free tstore pointer 
    }
    
}
```

There are multiple LLL examples of this in the contract directory.

## Compact version

The transient storage could be used to store call and return data. The EVM could use the address `0x00` to store the length (32 byte int), and the address `0x20` as the starting address data itself. This could also be the standard for contract languages.

This could be used by the EVM to copy the initial tx data into transient storage, and when writing return data from precompiled contracts.

The rule is the same as for returndata now: calldata and returndata remain valid until the next call (or create) is done from the code. Additionally, it also becomes invalid when tstorage data is manually overwritten.

LLL Example:

```
{ ;; body
    ;; STATE 1
    ;; Here, tstorage is guaranteed to be calldata from caller. It may not be
    ;; "correct" calldata, for example if the caller may have forgotten to write 
    ;; it in, but it is still the calldata.
    
    (TSTORE 0x0 5)
    ;; STATE 2
    ;; tstorage has been modified and is now invalid.
    
    ;; ... various other code that does not touch tstorage ...
    
    ;; STATE 3
    ;; whatever is in tstorage (length specified at address 0x00) will now be calldata 
    ;; for the receiver.
    (msg (CALLER) 0)
    
    ;; STATE 4
    ;; tstorage is now returndata from the call above.
    
    ;; ... various other code that does not touch tstorage ...
    
    ;; STATE 5
    ;; tstorage will now be return data for this execution
    (STOP)
}
```

This works, but it seems rather bug prone since the storage is not routinely cleared. If it is cleared by the VM (for example with a CALL it would take memory address and length params, clear tstorage and then write the new data, and similar for return) then it is better suited for passing messages but makes it useless for manual storage.