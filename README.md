<!--
-- DEPENDS:
-- #Install  tangerine.init
-- #Command  tangerine.vim.cmds
-- #Setup    tangerine.utils.env
-- #FAQ      tangerine.utils.env
-- #API      G.tangerine.api.**
-- #FAQ      G.tangerine.fennel
-- #API      G.tangerine.fennel
-- #Build    Makefile
-->

<!-- ignore-start -->
<div align="center">

# :tangerine: Tangerine :tangerine:

![Neovim version](https://img.shields.io/badge/Neovim-0.5-57A143?style=flat-square&logo=neovim)
![GNU Neovim version](https://img.shields.io/badge/Neovim%20In%20Emacs-0.5-dac?style=flat-square&logo=gnuemacs&logoColor=daf)

[About](#introduction) • [Installation](#installation) • [Setup](#setup) • [Commands](#commands) • [API](#api)

<p align="center">
    <img width="700" src="https://raw.githubusercontent.com/udayvir-singh/tangerine.nvim/master/demo/demo.svg">
</p>


</div>
<!-- ignore-end -->

# Introduction
Tangerine provides a painless way to add fennel to your neovim config, without adding to your load times.

It prioritizes speed, transparency and minimalism. It's blazing fast thanks to it diffing algorithm.

## Features
- Lighting fast compile times
- Smart diffing to only compile files that are stale
- Loads `init.fnl` automatically for you
- Abstracts away lua output from user
- Built-in support for interactive evaluation 

## Comparison to other plugins
- [Hotpot](https://github.com/rktjmp/hotpot.nvim) closest to this plugin, but hooks onto lua package searches to compile
- [Aniseed](https://github.com/Olical/aniseed) seems too bloated and focused on plugin developers rather than for dotfiles

Tangerine also compiles and loads `~/.config/nvim/init.fnl`, without it having to required by user.

Tangerine intends to be as fast and transparent as possible, it does most tedious heavy lifting for you, so you can easily configure neovim in fennel.

## Installation
1) create file `plugin/tangerine.lua` in your config dir

2) add these lines to automatically bootstrap tangerine
```lua
-- ~/.config/nvim/plugin/tangerine.lua

-- pick your plugin manager, default [standalone]
local pack = "tangerine" or "packer" or "paq"

local remote = "https://github.com/udayvir-singh/tangerine.nvim"
local tangerine_path = vim.fn.stdpath "data" .. "/site/pack/" .. pack .. "/start/tangerine.nvim"

if vim.fn.empty(vim.fn.glob(tangerine_path)) > 0 then
	print [[tangerine.nvim: installing in data dir... ]]
	vim.fn.system {"git", "clone", remote, tangerine_path}
	vim.cmd [[redraw]]
	print [[tangerine.nvim: finished installing ]]
end
```
3) call setup() function
```lua
-- ~/.config/nvim/plugin/tangerine.lua

local tangerine = require [[tangerine]]

tangerine.setup {}
```
4) create `~/.config/nvim/init.fnl`

5) invoke `:FnlCompile` to run tangerine or add hooks to automatically compile, see [setup](#setup) for more info.

6) add `tangerine.nvim` to your plugin list, if you are using a plugin manager

##### Packer
```fennel
(local packer (require :packer))

(packer.startup (fn []
	(use :udayvir-singh/tangerine.nvim)))
```

##### Paq
```fennel
(local paq (require :paq))

(paq {
	:udayvir-singh/tangerine.nvim
})
```

## Building From Source
### Requirements
| Program       | Description                     |
|---------------|---------------------------------|
| [pandoc]()    | for generating vimdoc           |
| [make]()      | for build instructions          |
| [lua]()       | for running fennel (included)   |
| [bash]()      | for running shell scripts       |
| [coreutils]() | required by shell scripts       |

### Git
```bash
git clone https://github.com/udayvir-singh/tangerine.nvim
cd tangerine.nvim

make <target>
```
see `make help` or [below](#make-targets) for information on targets.

### Make Targets
| Target     | Description                                |
|------------|--------------------------------------------|
| `:fnl`     | compiles fennel files                      |
| `:deps`    | copy required deps in lua folder           |
| `:vimdoc`  | runs panvimdoc to generate vimdocs         |
| `:build`   | combines `:fnl` `:deps` `:vimdoc`          |
| `:install` | install tangerine on this system           |
| `:clean`   | deletes build and install dir              |
| `:loc`     | pretty print lines of code in fennel files |

- To build tangerine run:
```console
$ make clean build
```

- Then to install it
```console
$ make install
```

# Setup
#### Default config
Tangerine uses sane defaults so that you can get going with having to add to your config.
```lua
local config = vim.stdpath [[config]]

{
	source = config .. "/fnl",
	target = config .. "/lua",
	vimrc  = config .. "/init.fnl",

	compiler = {
		verbose = true,     -- enable messages showing compiled files
		clean   = true,     -- delete stale lua files
		force   = false,    -- disable diffing (not recommended)
		version = "latest", -- version of fennel to use, possible values [ latest, 1-0-0, 0-10-0, 0-9-2 ]

		-- hooks for tangerine to compile on:
		-- "onsave" run every time you save fennel file in {target} dir.
		-- "onload" run on VimEnter event
		-- "oninit" run before sourcing init.fnl [recommended than onload]
		hooks   = []
	},

	diagnostic = {
		hl_normal  = "DiagnosticError",            -- hl group for errored lines
		hl_virtual = "DiagnosticVirtualTextError", -- hl group for virtual text
		timeout    = 10 -- how long should the error persist
	},
}
```

<details>
<summary>Here is schema used internally for validation</summary>

```fennel
{
	:source "string"
	:target "string"
	:vimrc  "string"
	:compiler {
		:verbose "boolean"
		:clean   "boolean"
		:force   "boolean"
		:version [:oneof ["latest" "1-0-0" "0-10-0" "0-9-2"]]
		:hooks   [:array ["onsave" "onload" "oninit"]]
	}
	:diagnostic {
		:hl_normal  "string"
		:hl_virtual "string"
		:timeout    "number"
	}
}
```
</details>

#### Example Config
Here is config that I use in my dotfiles
```lua
{
	-- save fnl output in a separate dir, it gets automatically added to package.path
	target = vim.fn.stdpath [[data]] .. "/tangerine"

	compiler = {
		-- compile every time changed are made to fennel files or on entering vim
		hooks = ["onsave", "oninit"]
	}
}
```

That's It now get writing your vim config in fennel

# Commands
<!-- doc=:FnlCompile -->
#### :FnlCompile
Diff and compile fennel files in `source` dir to `target` dir.

<!-- doc=:FnlCompileBuffer -->
#### :FnlCompileBuffer
Only compile current buffer of an fennel file

<!-- doc=:Fnl -->
#### :Fnl {expr}
Executes and Evalutate {expr} of fennel
```fennel
:Fnl (print "Hello World")
  -> Hello World

:Fnl (values some-var)
  -> :return [ 1 2 3 4 ]
```

<!-- doc=:FnlBuffer -->
#### :FnlBuffer
Evaluates all lines in current fennel buffer

<!-- doc=:FnlRange -->
#### :[range]FnlRange
Evaluates [range] of fennel in current buffer

<!-- doc=:FnlFile -->
#### :FnlFile {file}
Evaluates a file of fennel

```fennel
:FnlFile path/source.fnl

:FnlFile % ;; not recomended
```

<!-- doc=:FnlClean -->
#### :FnlClean
Checks and deletes stale and orphaned lua files in `target` dir

<!-- doc=:FnlGotoOutput -->
#### :FnlGotoOutput
Open output lua file of current fennel buffer in a new buffer

# FAQ and Tricks
##### Q: How to make tangerine compile automatically when you open vim
Ans: add hooks in config of `setup()` function:
```lua
-- if you want to compile before loading init.fnl (recommended)
hooks = ["oninit"]

-- if you only want after VimEnter event has fired
hooks = ["onenter"]
```

##### Q: How to tuck away compiled output in a separate directory
Ans: just change source in config
```lua
source = "/path/to/your/dir"
```

##### Get underlying fennel used by tangerine
Call `(tangerine.fennel {*version})` to fennel, see [fennel api](#fennel-api) for more info
```fennel
(tangerine.fennel (or :latest :1-0-0 :0-10-0 :0-9-2))
```

# Api
<!-- ignore-start -->
**NOTE: this section was formatted to be viewed by vimdoc,
see** `:h tangerine-api` **for better formatting**
<!-- ignore-end -->

By default tangerine provides the following api 
```fennel
:Fnl tangerine.api

-> :return {
  	:compile {
  		:all    <function 3>
  		:buffer <function 4>
  		:dir    <function 5>
  		:file   <function 6>
  		:string <function 7>
  		:vimrc  <function 8>
  	}
  	:clean {
  		:orphaned <function 1>
  		:target   <function 2>
  	}
  	:eval {
  		:buffer <function 9>
  		:file   <function 10>
  		:range  <function 11>
  		:string <function 12>
  	}
  	:goto_output <function 13>
	:serialize   <function 14>
  }
```

## Compiler Api
This section describes function for `tangerine.api.compile.{func}`

<!-- doc=tangerine.api.compile.string() -->
#### compile-string
<pre lang="fennel"><code> (compile.string {str})
</pre></code>

<ul><li>
Compiles string {str} of fennel, returns string of lua
</li></ul>

Can throw errors, upto users to handle them

<!-- doc=tangerine.api.compile.file() -->
#### compile-file
<pre lang="fennel"><code> (compile.file {path} {output})
</pre></code>

<ul><li>
Compiles fennel {path} and writes out to {output}
</li></ul>

Can throw errors, upto users to handle them

<!-- doc=tangerine.api.compile.buffer() -->
#### compile-buffer
<pre lang="fennel"><code> (compile-buffer {opts})
</pre></code>

<ul><li>
Compiles current fennel buffer
</li></ul>

opts can be of table:
```fennel
{
	:verbose <boolean>
}
```

<!-- doc=tangerine.api.compile.vimrc() -->
#### compile-vimrc
<pre lang="fennel"><code> (compile-vimrc {opts})
</pre></code>

<ul><li>

Compiles `config.vimrc` to `config.target/tangerine_vimrc.lua`

</li></ul>

opts can be of table:
```fennel
{
	:force <boolean>
	:verbose <boolean>
}
```
If {opts.force} != `true` then it diffs files for compiling

<!-- doc=tangerine.api.compile.all() -->
#### compile-all
<pre lang="fennel"><code> (compile.all {opts})
</pre></code>

<ul><li>

Compiles fennel files in `config.source` dir to `config.target` dir.

</li></ul>

opts can be of table:
```fennel
{
	:force <boolean>
	:verbose <boolean>
}
```
If {opts.force} != `true` then it diffs files for compiling

<!-- doc=tangerine.api.compile.dir() -->
#### compile-dir
<pre lang="fennel"><code> (compile-dir {source} {target} {opts})
</pre></code>

<ul><li>
Compiles fennel in file {source} dir to {target} dir
</li></ul>

opts can be of table:
```fennel
{
	:force <boolean>
	:verbose <boolean>
}
```
If {opts.force} != `true` then it diffs files for compiling

Example:
```fennel
(tangerine.api.compile.dir 
	:path/fnl 
	:path/lua
	{ :force true :verbose true })
```

## Cleaning Api
Tangerine comes with functions to clean stale lua file in target dir without their fennel parents.

This section describes function for `tangerine.api.clean.{func}`

<!-- doc=tangerine.api.clean.target() -->
#### clean-target
<pre lang="fennel"><code> (clean.target {target} {force})
</pre></code>

<ul><li>
Deletes lua files in {target} dir without their fennel parent
</li></ul>

If {force} == `true`, then it deletes all compiled files

<!-- doc=tangerine.api.clean.orphaned() -->
#### clean-orphaned
<pre lang="fennel"><code> (clean.orphaned {opts})
</pre></code>

<ul><li>

Deletes lua files in `config.target` dir without their fennel parent

</li></ul>

opts can be of table:
```fennel
{
	:force <boolean>
	:verbose <boolean>
}
```
If {opts.force} == `true`, then it deletes all compiled files

## Evaluation Api
This section describes function for `tangerine.api.eval.{func}`

<!-- doc=tangerine.api.eval.string() -->
#### eval-string
<pre lang="fennel"><code> (eval.string {str})
</pre></code>

<ul><li>
Evaluates string {str} of fennel, and prints the output
</li></ul>

Can throw errors

<!-- doc=tangerine.api.eval.file() -->
#### eval-file
<pre lang="fennel"><code> (eval.file {path})
</pre></code>

<ul><li>
Evaluates {path} of fennel, and prints the output
</li></ul>

Can throw errors

<!-- doc=tangerine.api.eval.range() -->
#### eval-range
<pre lang="fennel"><code> (eval.range {start} {end} {count})
</pre></code>

<ul><li>
Evaluates range {start} to {end} in vim buffer 0
</li></ul>

Optionally takes {count}, only meant to be used in command definitions

<!-- doc=tangerine.api.eval.buffer() -->
#### eval-buffer
<pre lang="fennel"><code> (eval.buffer)
</pre></code>

<ul><li>

Evaluates all lines in vim buffer 0,
wrapper around `(eval.range 1 -1)`

</li></ul>

## Utils Api
<!-- doc=tangerine.api.serialize() -->
#### serialize
<pre lang="fennel"><code> (tangerine.api.serialize {object})
</pre></code>

<ul><li>
Return a human-readable representation of given {object}
</li></ul>

Example:
```fennel
(tangerine.api.serialize [1 2 3 4])
-> "[ 1 2 3 4 ]"
```

<!-- doc=tangerine.api.goto_output() -->
#### goto_output
<pre lang="fennel"><code> (tangerine.api.goto_output)
</pre></code>

<ul><li>
Open lua source of current fennel buffer in a new buffer
</li></ul>

<!-- doc=tangerine.fennel() -->
## Fennel Api
Underlying fennel used by tangerine can by accessed by calling `tangerine.fennel`

<pre lang="fennel"><code> (tangerine.fennel {version})
</pre></code>

{version} can be one of [ `latest` `1-0-0` `0-10-0` `0-9-2` ],
default `config.compiler.version`

# The End
