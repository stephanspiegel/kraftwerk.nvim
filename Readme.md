# kraftwerk

> A neovim plugin for working with Salesforce sfdx

das Kraftwerk - German: Power plant, literally "force works"

This plugin adds wrapper commands and utilities to work on a modern Salesforce project in source format using sfdx-cli

For a much more mature plugin for working with older Salesforce projects in metadata API format, see [vim-force.com](https://github.com/neowit/vim-force.com) (vim only - no neovim support)

## Dependencies

* neovim v0.5.0
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
## Usage

### Commands

Most commands take an optional <alias> argument as the last argument, allowing them to be run against a different org than the current default. 

#### :ForceDataSoqlQuery <format> <alias>
Runs a SOQL query on a query highlighted in visual mode. Format can be one of:
* csv 
* human
* json
* table (not implemented yet)

The result of the query will be opened in its own buffer.

#### :ForceSourcePush <alias>

Push local changes to the cloud.

#### :ForceApexTestRun <test class or method> <alias>

Start a unit test run. If <test class or method> is given, run all tests in the class, or run the test method. Defaults to the test class open in the current buffer.

#### :ForceApexExecute <alias>

Run the visual selection as Anonymous Apex. The result log will be opened in its own buffer.

## Goes well with

### Apex Language Server
[https://developer.salesforce.com/tools/vscode/en/apex/language-server](https://developer.salesforce.com/tools/vscode/en/apex/language-server)
TODO: Instructions on how to set up

### SOQL Language Server
[https://github.com/forcedotcom/soql-language-server](https://developer.salesforce.com/tools/vscode/en/apex/language-server)
TODO: Instruction how to set up

### CSV.vim
[https://github.com/chrisbra/csv.vim](https://github.com/chrisbra/csv.vim)
For working with results of ForceDataSoqlQuery in csv format
