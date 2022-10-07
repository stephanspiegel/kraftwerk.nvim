# kraftwerk

> A neovim plugin for working with Salesforce sfdx

_das Kraftwerk_ - German: Power plant, literally "force works"

This plugin adds wrapper commands and utilities to work on a modern Salesforce project in source format using sfdx-cli

For a much more mature plugin for working with older Salesforce projects in metadata API format, see [vim-force.com](https://github.com/neowit/vim-force.com) (vim only - no neovim support)

## Dependencies

* neovim v0.7.0 or higher
* [sfdx-cli](https://developer.salesforce.com/tools/sfdxcli)

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'stephanspiegel/kraftwerk.nvim'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'stephanspiegel/kraftwerk.vim', }
```

## Configuration

If you don't like the defaults, call `require('kraftwerk).setup()`, passing in a setup object. The defaults look like this:

```lua
{
    sfdx_alias_config = '$HOME/.sfdx/alias.json',
    sfdx_executable = 'sfdx',
}
```
* `sfdx_alias_config`: Location of the `alias.json` file which sfdx auto-generates, containing information about all configured aliases. Used for username autocompletion.
* `sfdx_executable`: Name of the sfdx executable. Useful if you've aliased the executable to something else, or to specify the full path if it's not in the $PATH.

## Usage

### Commands

Most commands take an optional `<alias>` argument as the last argument, so you can run them against a different org than the current default. 

#### SOQL queries

```
:ForceDataSoqlQuery <format> <alias>
```
Runs a SOQL query on a query highlighted in visual mode. Format can be one of:
* csv 
* human
* json
* table (not implemented yet)

The result of the query will open in a separate buffer.

```
:ForceDataSoqlQuery! <format> <alias>
```

Same as `:ForceDataSoqlQuery`, but use Tooling API to run the query.

####  Push source
```
:ForceSourcePush <alias>
```

Push local changes to the cloud.

```
:ForceSourcePush! <alias>
```
Push changes, forcing overwrite of remote changes if there are any conflicts.

#### Run unit tests
```
:ForceApexTestRun <test class or method> <alias>
```

Start a unit test run. If `<test class or method>` is given, run all tests in the class, or run the test method. Defaults to the test class open in the current buffer.

Todo: autocompletion. Will probably need to wait for treesitter parser.

#### Run anonymous apex
```
:ForceApexExecute <alias>
```

Run code in the current buffer as Anonymous Apex. If there is a visual selection, runs the selected code, otherwise runs the entire buffer. The result log will open in a separate buffer.

#### Populate quickfix from log

```
:ForceApexUnstack
```

Take the visual selection and try to parse quickfix items from it.
You could use this to get the quickfix populated from an Apex log that contains
a stacktrace.

## Goes well with

### Apex Language Server

The [mason.nvim](https://github.com/williamboman/mason.nvim) plugin contains a [package for apex-language-server](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md#apex-language-server). You'll also want to install mason-lspconfig and lspconfig. The lspconfig plugin makes no assumptions about the location of the jar file for the language server, so you'll have to add that to your configs. This works for me:
```lua
require'lspconfig'.apex_ls.setup {
  apex_jar_path = vim.fn.stdpath("data")..'/mason/packages/apex-language-server/apex-jorje-lsp.jar', -- Where mason.nvim installs the jar file
  apex_enable_semantic_errors = false, -- Whether to allow Apex Language Server to surface semantic errors
  apex_enable_completion_statistics = false, -- Whether to allow Apex Language Server to collect telemetry on code completion usage
}
```

### SOQL Language Server
[https://github.com/forcedotcom/soql-language-server](https://developer.salesforce.com/tools/vscode/en/apex/language-server)

An [open issue](https://github.com/forcedotcom/soql-language-server/issues/43) prevents this from being too useful in editors besides VS Code.

The SOQL server is not yet included in mason.nvim/lspconfig, so there is some configuration work needed to include it locally:

```lua
-- Adding the SOQL LSP to lspconfig
-- See https://github.com/williamboman/mason.nvim/discussions/189
local Pkg = require "mason-core.package"
local npm = require "mason-core.managers.npm"
local path = require "mason-core.path"
local index = require("mason-registry.index")
index["soql_ls"] = Pkg.new {
    name = "soql-ls",
    desc = [[Language server for the Saleforce SOQL query language]],
    homepage = "https://github.com/forcedotcom/soql-language-server",
    languages = { Pkg.Lang.SOQL },
    categories = { Pkg.Cat.LSP },
    install = function(ctx)
        npm.packages { "@salesforce/soql-language-server" }()
        ctx:link_bin(
            "soql-ls",
            ctx:write_node_exec_wrapper(
                "soql-ls",
                path.concat { "node_modules", "@salesforce", "soql-language-server", "lib", "server.js" }
            )
        )
    end,
}

local configs = require 'lspconfig.configs'
-- Check if it's already defined for when reloading this file.
if not configs.soql_ls then
    configs.soql_ls = {
        default_config = {
            cmd = {'soql-ls', '--stdio'},
            filetypes = {'soql'},
            root_dir = lspconfig.util.root_pattern('sfdx-project.json'),
            settings = {},
        }
    }
end

lspconfig.soql_ls.setup() 
```
### CSV.vim
[https://github.com/chrisbra/csv.vim](https://github.com/chrisbra/csv.vim)

For working with results of ForceDataSoqlQuery in csv format
