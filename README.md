<!--
-- DEPENDS:
-- Install    | main
-- Setup, FAQ | utils[env]
-- Command    | vim[cmds]
-- API        | api
-- API        | fennel
-- Build      | make
-->

<!-- ignore-start -->
<div align="center">

# :tangerine: Tangerine :tangerine:

![Neovim version](https://img.shields.io/badge/Neovim-0.5-57A143?style=flat-square&logo=neovim)
![GNU Neovim in Emacs version](https://img.shields.io/badge/Neovim%20In%20Emacs-0.5-dac?style=flat-square&logo=gnuemacs&logoColor=daf)

[About](#about) • [Installation](#installation) • [Setup](#setup) • [Commands](#commands) • [API](#api) • [Development](#development)

<p align="center">
    <img width="700" src="https://user-images.githubusercontent.com/97400310/189345791-4ab2c6cc-3eb6-452a-937b-ace7fdeab9f5.svg">
</p>

</div>
<!-- ignore-end -->

# About

> Tangerine provides a painless way to add fennel to your config.

# Features

- :fire:   _BLAZING_ fast, compile times in milliseconds
- :ocean:  200% support for interactive evaluation
- :bamboo: Control over when and how to compile
- :ribbon: Natively loads `nvim/init.fnl`

# Comparison to other plugins

##### HOTPOT :stew:

- Abstracts too much away from the user.
- Hooks onto lua package searchers to compile [harder to debug]

##### ANISEED :herb:

- Excessively feature rich for use in dotfiles.
- Blindly compiles all files that it founds, resulting in slow load times.

# Installation

<details>
<summary>Standalone/Packer/Paq</summary>

```lua
-- ~/.config/nvim/plugin/0-tangerine.lua

-- pick your plugin manager, default [standalone]
local pack = "tangerine" or "packer" or "paq"

local function bootstrap(url, ref)
    local name = url:gsub(".*/", "")
    local path = vim.fn.stdpath("data") .. "/site/pack/".. pack .. "/start/" .. name

    if vim.fn.isdirectory(path) == 0 then
        print(name .. ": installing in data dir...")

        vim.fn.system {"git", "clone", url, path}
        if ref then
            vim.fn.system {"git", "-C", path, "checkout", ref}
        end

        vim.cmd "redraw"
        print(name .. ": finished installing")
    end
end

-- for stable version [recommended]
bootstrap("https://github.com/udayvir-singh/tangerine.nvim", "v2.6")

-- for git head
bootstrap("https://github.com/udayvir-singh/tangerine.nvim")

require "tangerine".setup {
    compiler = {
        hooks = { "onsave", "oninit" },
    }
}
```

See [config](#default-config) for full list of options that can be passed to Tangerine's `setup`.

</details>

<details>
<summary>Lazy</summary>

> Lazy requires some extra setup to get working, because it interferes with package path.

```lua
-- ~/.config/nvim/init.lua

local function bootstrap(url)
    local name = url:gsub(".*/", "")
    local path = vim.fn.stdpath "data" .. "/lazy/" .. name

    if vim.fn.isdirectory(path) == 0 then
        print(name .. ": installing in data dir...")

        vim.fn.system { "git", "clone", url, path }

        vim.cmd "redraw"
        print(name .. ": finished installing")
    end

    vim.opt.rtp:prepend(path)
end

bootstrap("https://github.com/udayvir-singh/tangerine.nvim")

require "tangerine".setup {
    compiler = {
        hooks = { "onsave", "oninit" },
    }
}
```

See [config](#default-config) for full list of options that can be passed to Tangerine's `setup`.

---

Now find the file where you call `require "lazy".setup()` and set `reset_packpath` to `false`:

```lua
require "lazy".setup(plugins, {
  performance = {
    reset_packpath = false,
  },
})
```

</details>

:tanabata_tree: Now start converting your Lua configs to Fennel.

:hibiscus: Optionally you can also install [hibiscus](https://github.com/udayvir-singh/hibiscus.nvim) for macros.

## (Optional) Version Management

Only do this if you haven't used `ref` option in bootstrap.

<details>
<summary>Packer</summary>

You can use packer to manage tangerine afterwards:

```fennel
(local packer (require :packer))

(packer.startup (lambda [use]
(use :udayvir-singh/tangerine.nvim)))
```

Using [hibiscus](https://github.com/udayvir-singh/hibiscus.nvim) macros:

```fennel
(require-macros :hibiscus.packer)

(packer-setup {}) ; bootstraps packer

(packer
(use! :udayvir-singh/tangerine.nvim))
```

</details>

<details>
<summary>Lazy</summary>

```fennel
(local lazy (require :lazy))

(lazy.setup
  [
   :udayvir-singh/tangerine.nvim
   ]
  {:performance {:reset_packpath false}})
```

</details>

<details>
<summary>Paq</summary>

```fennel
(local paq (require :paq))

(paq [
      :udayvir-singh/tangerine.nvim
      ])
```

</details>

# Setup

## Default config

Tangerine comes with sane defaults so that you can get going without having to add much to your config:

```lua
local nvim_dir = vim.fn.stdpath [[config]]

{
    vimrc   = nvim_dir .. "/init.fnl",
    source  = nvim_dir .. "/fnl",
    target  = nvim_dir .. "/lua",
    rtpdirs = {},

    custom = {
        -- list of custom [source target] chunks, for example:
        -- {"~/.config/awesome/fnl", "~/.config/awesome/lua"}
    },

    compiler = {
        float   = true,     -- show output in floating window
        clean   = true,     -- delete stale lua files
        force   = false,    -- disable diffing (not recommended)
        verbose = true,     -- enable messages showing compiled files

        globals = vim.tbl_keys(_G), -- list of alowedGlobals
        version = "latest",         -- version of fennel to use, [ latest, 1-3-0, 1-2-1, 1-2-0, 1-1-0, 1-0-0, 0-10-0, 0-9-2 ]

        -- hooks for tangerine to compile on:
        -- "onsave" run every time you save fennel file in {source} dir
        -- "onload" run on VimEnter event
        -- "oninit" run before sourcing init.fnl [recommended than onload]
        hooks   = {}
    },

    eval = {
        float  = true,      -- show results in floating window
        luafmt = function() -- function that returns formatter with flags for peeked lua
            return {"/path/lua-format", ...} -- optionally install lua-format by `$ luarocks install --server=https://luarocks.org/dev luaformatter`
        end,

        diagnostic = {
            virtual = true,  -- show errors in virtual text
            timeout = 10     -- how long should the error persist
        }
    },

    keymaps = {
        -- set them to <Nop> if you want to disable them
        eval_buffer = "gE",
        peek_buffer = "gL",
        goto_output = "gO",
        float = {
            next    = "<C-K>",
            prev    = "<C-J>",
            kill    = "<Esc>",
            close   = "<Enter>",
            resizef = "<C-W>=",
            resizeb = "<C-W>-"
        }
    },

    highlight = {
        float   = "Normal",
        success = "String",
        errors  = "DiagnosticError"
    },
}
```

## Example Config

Here is config that I use in my dotfiles:

```lua
{
    -- save fnl output in a separate dir, it gets automatically added to package.path
    target = vim.fn.stdpath [[data]] .. "/tangerine",

    -- compile files in &rtp
    rtpdirs = {
        "plugin",
        "colors",
        "$HOME/mydir" -- absolute paths are also supported
    },

    compiler = {
        -- disable popup showing compiled files
        verbose = false,

        -- compile every time you change fennel files or on entering vim
        hooks = {"onsave", "oninit"}
    }
}
```

# Commands

## Compiling

<!-- doc=:FnlCompileBuffer -->
### :FnlCompileBuffer

Compiles current active fennel buffer.

<!-- doc=:FnlCompile -->
### :FnlCompile[!]

Diff compiles all indexed fennel files.

If bang! is present then forcefully compiles all `source` files.

<!-- doc=:FnlClean -->
### :FnlClean[!]

Deletes stale or orphaned lua files in `target` dir.

If bang! is present then it deletes all compiled lua files.

## Evaluation

<!-- doc=:Fnl -->
### :Fnl {expr}

Executes and Evalutate {expr} of fennel.

```fennel
:Fnl (print "Hello World")
  -> Hello World

:Fnl (values some_var)
  -> :return [ 1 2 3 4 ]
```

<!-- doc=:FnlFile -->
### :FnlFile {file}

Evaluates {file} of fennel and outputs the result.

```fennel
:FnlFile path/source.fnl

:FnlFile % ;; not recommended
```

<!-- doc=:FnlBuffer -->
### :[range]FnlBuffer

Evaluates all lines or [range] in current fennel buffer.

> mapped to `gE` by default.

## Peeking

<!-- doc=:FnlPeek -->
### :[range]FnlPeek

Peek lua output for [range] in current fennel buffer.

> mapped to `gL` by default.

<!-- doc=:FnlGotoOutput -->
### :FnlGotoOutput

Open lua output of current fennel buffer in a new buffer.

> mapped to `gO` by default.

## Window

<!-- doc=:FnlWinNext -->
### :FnlWinNext [N]

Jump to [N]th next floating window created by tangerine..

> mapped to `CTRL-K` in floats by default.

<!-- doc=:FnlWinPrev -->
### :FnlWinPrev [N]

Jump to [N]th previous floating window created by tangerine.

> mapped to `CTRL-J` in floats by default.

<!-- doc=:FnlWinResize -->
### :FnlWinResize [N]

Increase or Decrease floating window height by [N] factor.

> mapped to `CTRL-W =` to increase and `CTRL-W -` decrease by default.

<!-- doc=:FnlWinClose -->
### :FnlWinClose

Closes current floating window under cursor.

> mapped to `ENTER` in floats by default.

<!-- doc=:FnlWinKill -->
### :FnlWinKill

Closes all floating windows made by tangerine.

> mapped to `ESC` in floats by default.

# FAQ

**Q: How to make tangerine compile automatically when you open vim**

**A:** add hooks in config:

```lua
require [[tangerine]].setup {
    compiler = {
        -- if you want to compile before loading init.fnl (recommended)
        hooks = {"oninit"}

        -- if you want to compile after VimEnter event has fired
        hooks = {"onenter"}
    }
}
```

<br>

**Q: How to tuck away compiled output in a separate directory**

**A:** change target in config:

```lua
require [[tangerine]].setup {
    target = "/path/to/your/dir"
}
```

<br>

**Q: How to make impatient work with tangerine**

**A:** bootstrap and require impatient before calling tangerine:

```lua
bootstrap "https://github.com/lewis6991/impatient.nvim"

require [[impatient]]

require [[tangerine]].setup {...}
```

<br>

**Q: How to use lua files interchangeably with fennel files**

**A:** lua files can simply be stored in `fnl` dir:

```
fnl
├── options.lua
└── autocmd.fnl
```

```fennel
; require both as normal modules in your config
(require :options)
(require :autocmd)
```

<br>

**Q: How to fix errors in macros while migrating from hotpot**

**A:** make sure that macro files are suffixed with `-macros.fnl`.

```
utils
├── neovim-macros.fnl
└── packer-macros.fnl
```

see [#2](https://github.com/udayvir-singh/tangerine.nvim/issues/2) for more information

# Api

By default tangerine provides the following api:

```fennel
:Fnl tangerine.api

-> :return {
     :compile {
       :all    (function 0)
       :buffer (function 1)
       :custom (function 2)
       :dir    (function 3)
       :file   (function 4)
       :rtp    (function 5)
       :string (function 6)
       :vimrc  (function 7)
     }
     :clean {
       :rtp      (function 8)
       :target   (function 9)
       :orphaned (function 10)
     }
     :eval {
       :buffer (function 11)
       :file   (function 12)
       :peek   (function 13)
       :string (function 14)
     }
     :win {
       :next    (function 15)
       :prev    (function 16)
       :close   (function 17)
       :killall (function 18)
       :resize  (function 19)
     }
     :goto_output (function 20)
     :serialize   (function 21)
   }
```

## Compiler Api

<!-- doc=tangerine.api.compile.string() -->
#### compile-string

<pre lang="fennel"><code> (compile.string {str} {opts?})
</pre></code>

Compiles string {str} of fennel, returns string of lua.

##### Parameters:

```fennel
{
    :filename <string>
    :globals  <list>
}
```

<!-- doc=tangerine.api.compile.file() -->
#### compile-file

<pre lang="fennel"><code> (compile.file {source} {target} {opts?})
</pre></code>

Compiles fennel {source} and writes output to {target}.

##### Parameters:

```fennel
{
    :filename <string>
    :globals  <list>
}
```

<!-- doc=tangerine.api.compile.dir() -->
#### compile-dir

<pre lang="fennel"><code> (compile-dir {source} {target} {opts?})
</pre></code>

Diff compiles files in {source} dir and outputs to {target} dir.

##### Parameters:

```fennel
{
    :force   <boolean>
    :float   <boolean>
    :verbose <boolean>
    :globals <list>
}
```

{opts.force} disables diffing if set to `true`

##### Example:

```fennel
(tangerine.api.compile.dir
    :path/fnl
    :path/lua
    { :force false :float true :verbose true })
```

<!-- doc=tangerine.api.compile.buffer() -->
#### compile-buffer

<pre lang="fennel"><code> (compile-buffer {opts?})
</pre></code>

Compiles the current active fennel buffer.

##### Parameters:

```fennel
{
    :float    <boolean>
    :verbose  <boolean>
    :filename <string>
    :globals  <list>
}
```

<!-- doc=tangerine.api.compile.vimrc() -->
#### compile-vimrc

<pre lang="fennel"><code> (compile-vimrc {opts?})
</pre></code>

Diff compiles `config.vimrc` to `config.target` dir.

##### Parameters:

```fennel
{
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :filename <string>
    :globals  <list>
}
```

{opts.force} disables diffing if set to `true`

<!-- doc=tangerine.api.compile.rtp() -->
#### compile-rtp

<pre lang="fennel"><code> (compile.rtp {opts?})
</pre></code>

Diff compiles fennel files in `config.rtpdirs` or {opts.rtpdirs}.

##### Parameters:

```fennel
{
    :rtpdirs  <list>
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :globals  <list>
}
```

{opts.force} disables diffing if set to `true`

##### Example:

```fennel
(tangerine.api.compile.rtp {
    :rtpdirs ["colors" "plugin" "$HOME/mydir"]
    :force   false
    :float   true
    :verbose true })
```

<!-- doc=tangerine.api.compile.custom() -->
#### compile-custom

<pre lang="fennel"><code> (compile.custom {opts?})
</pre></code>

Diff compiles fennel files indexed in `config.custom` or {opts.custom}.

##### Parameters:

```fennel
{
    :custom   <list>
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :globals  <list>
}
```

{opts.force} disables diffing if set to `true`

##### Example:

```fennel
(tangerine.api.compile.custom {
    :custom  [["~/path/fnl" "~/path/lua"]]
    :force   false
    :float   true
    :verbose true })
```

<!-- doc=tangerine.api.compile.all() -->
#### compile-all

<pre lang="fennel"><code> (compile.all {opts?})
</pre></code>

Diff compiles all indexed fennel files in `config`.

##### Parameters:

```fennel
{
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :globals  <list>
    :rtpdirs  <list>
    :custom   <list>
}
```

{opts.force} disables diffing if set to `true`

## Cleaning Api

Provides functions to clean stale / orphaned lua files in target dirs.

<!-- doc=tangerine.api.clean.target() -->
#### clean-target

<pre lang="fennel"><code> (clean.target {source} {target} {opts?})
</pre></code>

Deletes orphaned? {target} after comparing against {source}.

##### Parameters:

```fennel
{
    :force <boolean>
}
```

{opts.force} deletes {target} without comparing if set to `true`

#### clean-rtp

<pre lang="fennel"><code> (clean.rtp {opts?})
</pre></code>

Deletes all orphaned lua files in `config.rtpdirs` or {opts.rtpdirs}.

##### Parameters:

```fennel
{
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :rtpdirs  <list>
}
```

{opts.force} deletes all compiled files if set to `true`

<!-- doc=tangerine.api.clean.orphaned() -->
#### clean-orphaned

<pre lang="fennel"><code> (clean.orphaned {opts?})
</pre></code>

Deletes all orphaned lua files indexed inside `target` dirs.

##### Parameters:

```fennel
{
    :force    <boolean>
    :float    <boolean>
    :verbose  <boolean>
    :rtpdirs  <list>
}
```

{opts.force} deletes all compiled files if set to `true`

## Evaluation Api

<!-- doc=tangerine.api.eval.string() -->
#### eval-string

<pre lang="fennel"><code> (eval.string {str} {opts?})
</pre></code>

Evaluates string {str} of fennel, pretty prints the output.

##### Parameters:

```fennel
{
    :float    <boolean>
    :virtual  <boolean>
    :filename <string>
    :offset   <number> ;; line offset for errors
}
```

<!-- doc=tangerine.api.eval.file() -->
#### eval-file

<pre lang="fennel"><code> (eval.file {path} {opts?})
</pre></code>

Evaluates {path} of fennel, pretty prints the output.

##### Parameters:

```fennel
{
    :float    <boolean>
    :virtual  <boolean>
    :filename <string>
}
```

<!-- doc=tangerine.api.eval.buffer() -->
#### eval-buffer

<pre lang="fennel"><code> (eval.buffer {start} {end} {opts?})
</pre></code>

Evaluates lines {start} to {end} in current fennel buffer.

##### Parameters:

```fennel
{
    :float    <boolean>
    :virtual  <boolean>
    :filename <string>
}
```

<!-- doc=tangerine.api.eval.peek() -->
#### eval-peek

<pre lang="fennel"><code> (eval.peek {start} {end} {opts?})
</pre></code>

Peek lua output for lines {start} to {end} inside a scratch buffer.

##### Parameters:

```fennel
{
    :float    <boolean>
    :virtual  <boolean>
    :filename <string>
}
```

## Utils Api

<!-- doc=tangerine.api.goto_output() -->
#### goto_output

<pre lang="fennel"><code> (tangerine.api.goto_output)
</pre></code>

Open lua source of current fennel buffer in a new buffer.

<!-- doc=tangerine.api.serialize() -->
#### serialize

<pre lang="fennel"><code> (tangerine.api.serialize {...})
</pre></code>

Returns human-readable representation of {...}.

##### Example:

```fennel
(tangerine.api.serialize example)
-> ":return [ 1 2 3 4 ]"
```

## Windows Api

Provides functions to interact with floating windows created by tangerine.

<!-- doc=tangerine.api.win.next() -->
#### win-next

<pre lang="fennel"><code> (tangerine.api.win.next {steps?})
</pre></code>

Switch to next floating window by 1 or N {steps?}.

<!-- doc=tangerine.api.win.prev() -->
#### win-prev

<pre lang="fennel"><code> (tangerine.api.win.prev {steps?})
</pre></code>

Switch to previous floating window by 1 or N {steps?}.

<!-- doc=tangerine.api.win.resize() -->
#### win-resize

<pre lang="fennel"><code> (tangerine.api.win.resize {factor})
</pre></code>

Changes height of current floating window by {factor} of N.

<!-- doc=tangerine.api.win.close() -->
#### win-close

<pre lang="fennel"><code> (tangerine.api.win.close)
</pre></code>

Closes current floating window, switching to nearest neighbor afterwards.

<!-- doc=tangerine.api.win.killall() -->
#### win-killall

<pre lang="fennel"><code> (tangerine.api.win.killall)
</pre></code>

Closes all floating windows created by tangerine.

## Fennel Api

<!-- doc=tangerine.fennel() -->
#### fennel-load

<pre lang="fennel"><code> (tangerine.fennel {version?})
</pre></code>

Provides access to fennel compiler used by tangerine.

{version} can be one of [ `"latest"` `"1-3-0"` `"1-2-1"` `"1-2-0"` `"1-1-0"` `"1-0-0"` `"0-10-0"` `"0-9-2"` ]

<!-- ignore-start -->

# Development

## Requirements

| Program                                             | Description                   |
| --------------------------------------------------- | ----------------------------- |
| [pandoc](https://github.com/jgm/pandoc)             | generates vimdoc              |
| [lua](https://www.lua.org)                          | runs included fennel          |
| [make](https://www.gnu.org/software/make)           | runs build instructions       |
| [watchexec](https://github.com/watchexec/watchexec) | build on changes (optional)   |
| [bash](https://www.gnu.org/software/bash)           | runs shell scripts            |
| utils                                               | coreutils findutils gawk curl |

> only GNU utils work; 9base or busybox should not work

## Building from source

```bash
git clone https://github.com/udayvir-singh/tangerine.nvim
cd tangerine.nvim

make <git-hooks>
make <target>
```

see `make help` or [below](#make-targets) for information on targets.

## Make Targets

| Target        | Description                                  |
| ------------- | -------------------------------------------- |
| `fnl`         | compiles fennel files                        |
| `deps`        | copy required deps in lua folder             |
| `vimdoc`      | runs panvimdoc to generate vimdocs           |
| `fnldoc`      | generates module level documentation         |
|               |                                              |
| `build`       | combines `fnl` `deps` `vimdoc` `fnldoc`      |
| `watch-build` | watches source dir, runs `:build` on changes |
|               |                                              |
| `clean`       | deletes build and install dir                |
| `install`     | install tangerine on this system             |
|               |                                              |
| `runner`      | compiles test runner library                 |
| `test`        | runs unit tests, will erase nvim config      |

To build tangerine run:

```bash
$ make clean build
# or
$ make watch-build
```

To install tangerine run:

```bash
$ make install
```

## Git Hooks

| Target       | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `git-pull`   | safely fetches git repo, prevents conflicts with local changes |
| `git-skip`   | makes git ignore changes to build files                        |
| `git-unskip` | reverts `git-skip`, makes build files trackable                |

##### Example workflow:

```bash
$ make git-skip # first thing that you should be running

# makes changes to tangerine
$ ...
$ make clean build

# commit changes
$ git commit -a -m "<msg>"

# cleanly fetch from origin
$ make git-pull
```

## LOC Helpers

Helpers to generate detailed summary about lines of code in source files:

```bash
$ make loc-{language}
```

##### Supported Languages:

- `fennel` / `test`
- `bash`
- `markdown`
- `makefile`
- `yaml`

##### Examples:

```bash
$ make loc-fennel

$ make loc-bash
```

<!-- ignore-end -->

---

<!-- ignore-start -->
<p align="center">
:: おれとして白眼くらする蛙かな ::
</p>
<!-- ignore-end -->
