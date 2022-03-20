# cmds.fnl
> Defines tangerine's default vim commands.

**DEPENDS:**
```
_G.tangerine.api
```

**EXPORTS**
```fennel
:cmds [ true ]
```

# hooks.fnl
> Defines autocmd hooks as described in ENV.

**DEPENDS:**
```
_G.tangerine.api
utils[env]
```

**EXPORTS**
```fennel
:hooks {
  :oninit <function 1>
  :onload <function 2>
  :onsave <function 3>
  :run <function 4>
}
```

# maps.fnl
> Defines mappings for vim[cmds] as described in ENV.

**DEPENDS:**
```
utils[env]
vim[cmds]
```

**EXPORTS**
```fennel
:maps [ true ]
```

