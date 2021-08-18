local sfdx_runner = require("kraftwerk.sfdx_runner")
local echo = require("kraftwerk.echo")

local function sfdx_is_installed()
    local is_installed = vim.fn.executable("sfdx")
    if (is_installed == 0) then
        return false
    end
    return true
end

local oldest_supported_version = "7.110.0"

local function version_parts(version)
    local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    return major, minor, patch 
end

local function version_is_supported(version_number)
    local good_major, good_minor, good_patch = version_parts(oldest_supported_version)
    local found_major, found_minor, found_patch = version_parts(version_number)
    if found_major < good_major then
        return false
    elseif found_minor < good_minor then
        return false
    elseif found_patch < good_patch then
        return false
    else
        return true
    end
end

local function on_success(result)
    local version_number = string.gsub(result.cliVersion,"sfdx%-cli/", "")
    if not version_is_supported(version_number) then
        echo.err("Found sfdx version "..version_number.. ". Need version "..oldest_supported_version.." or higher.")
        return
    end
    echo.info("sfdx version check ✓")
end

local function check_sfdx_version()
    if not sfdx_is_installed() then
        echo.err("No sfdx executable found. See https://github.com/salesforcecli/sfdx-cli for install instructions")
        return
    end
    sfdx_runner.call_sfdx('--version', on_success)
end

return {
    check_sfdx_version = check_sfdx_version
}
