# clean.fnl
> Functions to clean stale lua files in target dirs.

**DEPENDS:**
```
output[logger]
utils[diff]
utils[env]
utils[fs]
utils[path]
```

**EXPORTS**
```fennel
:clean
```

# compile.fnl
> Functions to diff compile fennel files.

**DEPENDS:**
```
fennel
output[err]
output[log]
utils[diff]
utils[env]
utils[fs]
utils[path]
```

**EXPORTS**
```fennel
:compile
```

# eval.fnl
> Functions for interactive fennel evaluation.

**DEPENDS:**
```
fennel
output[display]
output[error]
utils[fs]
utils[path]
```

**EXPORTS**
```fennel
:eval
```

