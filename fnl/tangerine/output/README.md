# display.fnl
> Displays serialized evaluation results.

**DEPENDS:**
```
utils[env]
utils[serialize]
utils[window]
```

**EXPORTS**
```fennel
:display {
	:show     (function 1)
	:show-lua (function 2)
}
```

# error.fnl
> Sends headache of errors made by devs' to the users.

**DEPENDS:**
```
utils[env]
utils[window]
```

**EXPORTS**
```fennel
:error {
	:clear    (function 1)
	:compile? (function 2)
	:float    (function 3)
	:handle   (function 4)
	:parse    (function 5)
	:send     (function 6)
	:soft     (function 7)
}
```

# logger.fnl
> Displays compiler success/failure logs to the users.

**DEPENDS:**
```
utils[env]
utils[window]
```

**EXPORTS**
```fennel
:logger {
	:failure       (function 1)
	:float-failure (function 2)
	:float-success (function 3)
	:print-failure (function 4)
	:print-success (function 5)
	:success       (function 6)
}
```

