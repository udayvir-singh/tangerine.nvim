# diff.fnl
> Contains diffing algorithm used by compiler.

Works by creating marker that looks like `-- :fennel:<UTC>`,
compares UTC in marker to ftime(source).

**EXPORTS**
```fennel
:diff {
  :create-marker <function 1>
  :read-marker <function 2>
  :stale? <function 3>
}
```

# env.fnl
> Stores environment used by rest of tangerine

Provides getter and setter so that multiple modules can have shared configurations.

**EXPORTS**
```fennel
:env {
  :conf <function 1>
  :get <function 2>
  :set <function 3>
}
```

# fs.fnl
> Basic utils around file system handlers.

**EXPORTS**
```fennel
:fs {
  :dir-exists? <function 1>
  :dirname <function 2>
  :mkdir <function 3>
  :read <function 4>
  :readable? <function 5>
  :remove <function 6>
  :write <function 7>
}
```

# path.fnl
> Provides path manipulation and indexing functions

**DEPENDS:**
```
utils[env]
```

**EXPORTS**
```fennel
:path {
  :from-x-to-y <function 1>
  :goto-output <function 2>
  :list-fnl-files <function 3>
  :list-lua-files <function 4>
  :resolve <function 5>
  :shortname <function 6>
  :source <function 7>
  :target <function 8>
  :wildcard <function 9>
}
```

# window.fnl
> Contains functions to create and control floating windows.

**DEPENDS:**
```
utils[env]
```

**EXPORTS**
```fennel
:window {
  :close <function 1>
  :create-float <function 2>
  :killall <function 3>
  :next <function 4>
  :prev <function 5>
  :resize <function 6>
  :set-float <function 7>
}
```

