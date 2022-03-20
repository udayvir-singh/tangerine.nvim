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
:clean {
  :orphaned <function 1>
  :rtp <function 2>
  :target <function 3>
}
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
:compile {
  :all <function 1>
  :buffer <function 2>
  :dir <function 3>
  :file <function 4>
  :rtp <function 5>
  :string <function 6>
  :vimrc <function 7>
}
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
:eval {
  :buffer <function 1>
  :file <function 2>
  :peak <function 3>
  :string <function 4>
}
```

