New instructions added to LLLC. Modified compiler can be found at https://github.com/androlo/solidity, on the 'tstore' and 'tstore_compact' branches. Include `-DLLL=ON` when running cmake. 


#### Usage example, big implementation

```
{
	(def "T_INIT_ADDR" 0x00)
	(def "T_MSG_ADDR" 0x20)

	(def "tInit" (TLOAD (ADDRESS) T_INIT_ADDR))
	(def "tMsg" (TLOAD (ADDRESS) T_MSG_ADDR))

	(def "tInitW" (val) (TSTORE T_INIT_ADDR val))
	(def "tMsgW" (val) (TSTORE T_MSG_ADDR val))

	(def "StaticInit" 
	    (unless tInit {
		(tInitW 0x01)
		(tMsgW 0x00)
	    })
	)

    StaticInit
	
	[0x20] (create {
	
		StaticInit

		(returnlll {
			StaticInit
			(when (= (TLOAD (CALLER) T_MSG_ADDR) "Here's ur message.") (tMsgW "Thanks, bro."))
			(return 0)
		})
	})

	(tMsgW "Here's ur message.")
	(msg @0x20 0)
	[[0x00]] (TLOAD @0x20 T_MSG_ADDR)
}
```

#### Usage example, compact implementation

```
{
	(def "T_INIT_ADDR" 0x00)
	(def "T_MSG_ADDR" 0x20)

	(def "tInit" (TLOAD T_INIT_ADDR))
	(def "tMsg" (TLOAD T_MSG_ADDR))

	(def "tInitW" (val) (TSTORE T_INIT_ADDR val))
	(def "tMsgW" (val) (TSTORE T_MSG_ADDR val))
	
	[0x20] (create {

		(returnlll {
			(when (= tMsg "Here's ur message.") (tMsgW "Thanks, bro."))
			(return 0)
		})
	})

	(tMsgW "Here's ur message.")
	(msg @0x20 0)
	[[0x00]] tMsg ;; should be "Thanks, bro." in ascii (right padded).
}
```

This contract does basic message passing without utilizing calldata or return data. It also performs a static initialization in the body, as well as in both init and body of the deployed contract, to make sure that transient variables are properly initialized.