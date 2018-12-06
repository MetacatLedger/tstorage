# Overview

`TSTORE sAddr val - store 'val' at tStore(_ADDRESS_)[sAddr]`

`TLOAD accAddr sAddr - read the value at tStore(accAddr)[sAddr]`

(maybe) `TCOPY accAddr sAddr len memAddr - copy 'len' bytes starting at tStore(accAddr)[sAddr] to memory position 'memAddr'`

### Calls using readonly call-, and return-data.

`CALL gas addr value memPos memSize`

`RETURN memAddr memSize`

`tStore(0)` is a byte array with word size 32 (like memory), laid out as such:

`[callPos, callLen, retPos, retLen, nextFree, ....]`

- Position 0x00: position of calldata
- Position 0x20: length of call data
- Position 0x40: position of the return data
- Position 0x60: length of the return data
- Position 0x80: next free address

This would be pre-populated by txdata. If it is a transaction to a function with signature `0xAAAAAAAA` and no arguments then it would initially look like this:

`[0x00 0x80 0x00 0x00 0x84 AA AA AA AA 00 00 00 00 ...]`

The 0x prefixed values are shorthand for right-aligned 32 byte values.

#### Making a call

`CALL` - writes data from memory to `tStore(0)` and calls.

The receiving contract gets the data from `tStore(0)` using the `callPos` and `callLen` values. They can either copy all the data to memory, or work with it from tstore directly (although they should at least copy the indices).

If the receiving contract returns data, `RETURN` will set `retPos` and `retLen` in `tStore(0)` to the correct values.

#### Notes

This would mean changes to the `CALL` and `RETURN` instructions, implemented at the VM level.

`CALLDATA` and `RETURNDATA` would become "volatile" in that the various positions and size values could potentially change during runtime (when calls are made), meaning these values should be copied as soon as possible. For that reason, those instructions would probably have to be deprecated in favor of `TLOAD`.

Example of reading calldata:

```
assembly {
	let cdPos := tLoad(0, 0)
	let cdLen := tLoad(0, 0x20)
	if (lt(cdLen, 4)) {
	    revert()
	}
	// ...
}
```

Example of reading returndata:

```
assembly {
	let retPos := tLoad(0, 0x40)
	let retLen := tLoad(0, 0x60)
	// ...
}
```

### Calls using ordinary call-, and return-data

`CALL gas addr value`

`RETURN`

Unlike the readonly version, this requires no params for position and size for either `CALL` or `RETURN`, but expects the proper tStore values to be already set.

`tStore(_ADDRESS_)` (for every address) would use the same layout as for `tStore(0)` in the previous section:

`[callPos, callLen, retPos, retLen, staticInit, nextFree, ....]`

(Info on staticInit is found in the next section)

To read calldata, each contract would use `tStore(CALLER)` instead of `tStore(0)`, but it would work the same as in the readonly version. To bootstrap an external transaction, the VM has to populate `tStore` for the calling address. When it does, it could skip the return + free mem data and only use [cdPos (0x40), cdLen, txdata ... ]. 

To read returndata, contracts would just read retPos and retSize from the `tStore` of the address it sent the most recent call to.

`CALL` expects `tStore` to be prepared for the own contract.

`RETURN` expects `tStore` to be prepared for the own contract.

`CALLDATA` and `RETURNDATA` would become volatile, just as in read only, so the same caveats apply.

Example of reading calldata:

```
assembly {
	let cdPos := tLoad(caller(), 0)
	let cdLen := tLoad(caller(), 0x20)
	// ...
}
```

Example of reading returndata:

```
assembly {
	let target := 0x...
	// call( ... )
	let retPos := tLoad(target, 0x40)
	let retLen := tLoad(target, 0x60)
	// ...
}
```

### Using tStore in code

The `static` flag, or `transient`, or some other keyword, could be used to declare fields that are bound to the contract (account) over the span of an entire transaction rather then the instance of the currently running VM. `transient` may be preferable as `static` could have implications.

Usage is complicated. Declaring these variables as fields would be ideal so they can be used to lock down storage fields. The question is how to initialize them and give them a unique location. This is somewhere between how storage and memory works.

A type of "static initialization" could be done using a reserved field.

```
assembly {
    if(iszero(tload(0x80)) {
    t
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