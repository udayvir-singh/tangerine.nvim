# diff.fnl
> Contains diffing algorithm used by compiler.

Works by creating marker that looks like `-- :fennel:<UTC>`,
compares UTC in marker to ftime(source).

**EXPORTS**
```fennel
:diff
```

# env.fnl
> Stores environment used by rest of tangerine

Provides getter and setter so that multiple modules can have shared configurations.

**EXPORTS**
```fennel
:env
```

# fs.fnl
> Basic utils around file system handlers.

**EXPORTS**
```fennel
:fs
```

# path.fnl
> Provides path manipulation and indexing functions

**DEPENDS:**
```
utils[env]
```

**EXPORTS**
```fennel
:path
```

# window.fnl
> Contains functions to create and control floating windows.

**DEPENDS:**
```
utils[env]
```

**EXPORTS**
```fennel
:window
```

