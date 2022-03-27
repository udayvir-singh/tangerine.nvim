# cmds.fnl
> Defines tangerine's default vim commands.

**DEPENDS:**
```
_G.tangerine.api
```

**EXPORTS**
```fennel
:cmds
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
:hooks
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
:maps
```

