# kraftwerk

> A neovim plugin for working with Salesforce sfdx

This plugin adds wrapper commands and utilities to work on a modern Salesforce project in source format using sfdx-cli

For a much more mature plugin for working with older Salesforce projects in metadata API format, see [vim-force.com](https://github.com/neowit/vim-force.com) (vim only - no neovim support)

## Dependencies

* neovim
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

### :AuthWebLogin
* Inputs:
    * username


### :DiffWithRemote -> custom
* Inputs:
    * username (autocomplete)
    * filename (implied)

### :ForceApexClassCreate
* Inputs:
    * classname
    * directory (autocomplete on dirs containing *.cls?)

### :ForceApexExecute
* Inputs:
    * Selection OR range OR buffer content
    * username (autocomplete)

### :ForceApexLogList
* Inputs:
    * username (autocomplete)
    * telescope/tui to select log?
    
### :ForceApexLogTail
* Inputs:
    * username (autocomplete)

### :ForceApexTestReport
* Inputs:
    * username (autocomplete)
    * report id (autocomplete? telescope?)
    
### :ForceApexTestRun
* Inputs:
    * test suite (autocomplete) OR test class (implied? autocomplete?) OR test method (cursor position? autocomplete?)
    * username (autocomplete)
### :ForceDataBulkDelete
### :ForceDataBulkUpsert
### :ForceDataSoqlQuery
* Inputs:
    * result format
### :ForceOrgCreate
### :ForceOrgList
### :ForceOrgOpen
### :ForceSourceDeploy
### :ForceSourcePull
### :ForceSourcePush
### :ForceSourceRetrieve
### :ForceStaticresourceCreate

### Suggested Mappings

## Goes well with


