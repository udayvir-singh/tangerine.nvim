# fennel.fnl
> Configures fennel and provides functions to load fennel bins.

**DEPENDS:**
```
fennel[*]
utils[env]
```

**EXPORTS**
```fennel
:fennel {
  :load <function 1>
  :patch-path <function 2>
}
```

# api/
| MODULE                                   | DESCRIPTION                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
|     [clean.fnl](./api/clean.fnl)         | Functions to clean stale lua files in target dirs.           |
|   [compile.fnl](./api/compile.fnl)       | Functions to diff compile fennel files.                      |
|      [eval.fnl](./api/eval.fnl)          | Functions for interactive fennel evaluation.                 |

# output/
| MODULE                                   | DESCRIPTION                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
|   [display.fnl](./output/display.fnl)    | Serializes evaluation results and pretty prints them.        |
|     [error.fnl](./output/error.fnl)      | Sends headache of errors made by devs' to the users.         |
|    [logger.fnl](./output/logger.fnl)     | Displays compiler success/failure logs to the users.         |

# utils/
| MODULE                                   | DESCRIPTION                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
|      [diff.fnl](./utils/diff.fnl)        | Contains diffing algorithm used by compiler.                 |
|       [env.fnl](./utils/env.fnl)         | Stores environment used by rest of tangerine                 |
|        [fs.fnl](./utils/fs.fnl)          | Basic utils around file system handlers.                     |
|      [path.fnl](./utils/path.fnl)        | Provides path manipulation and indexing functions            |
|    [window.fnl](./utils/window.fnl)      | Contains functions to create and control floating windows.   |

# vim/
| MODULE                                   | DESCRIPTION                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
|      [cmds.fnl](./vim/cmds.fnl)          | Defines tangerine's default vim commands.                    |
|     [hooks.fnl](./vim/hooks.fnl)         | Defines autocmd hooks as described in ENV.                   |
|      [maps.fnl](./vim/maps.fnl)          | Defines mappings for vim[cmds] as described in ENV.          |

