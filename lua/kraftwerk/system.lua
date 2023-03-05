local sfdx_runner = require("kraftwerk.sfdx_runner")
local health = vim.health
local config = require("kraftwerk.config")
local functor = require("kraftwerk.util.functor")

local oldest_supported_version = "7.190.2"

local function get_sfdx_executable()
    local sfdx_executable = 'sfdx'
    local executable = config.get('sfdx_executable')
    if  executable ~= nil then
        sfdx_executable = executable
    end
    return sfdx_executable
end

local function sfdx_is_installed()
    local is_installed = vim.fn.executable(get_sfdx_executable())
    return (is_installed == 1)
end

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

local function check_health()
    health.report_start("Check sfdx-cli")
    if sfdx_is_installed() then
        health.report_ok("Found sfdx executable")
    else
        health.report_error("Couldn't find sfdx", {
                "run in shell: npm install sfdx-cli --global",
                "see install instructions: https://developer.salesforce.com/tools/sfdxcli",
                "make sure sfdx is in your path environment variable",
                "(optional): specify sfdx-cli executable along with full path in g:kraftwerk_sfdx_executable"
            })
        return
    end
    local version_result = sfdx_runner.call_sfdx_sync({'version'})
    if not functor.has_key(version_result, 'cliVersion') then
        local advice = {}
        local sfdx_executable = get_sfdx_executable()
        if sfdx_executable ~= 'sfdx' then
            table.insert(advice, 'The sfdx_executable is configured to be `'..sfdx_executable..'`. Is this correct?')
            table.insert(advice, 'Make sure that `'..sfdx_executable..'` resolves to the sfdx-cli executable file')
        end
        health.report_error("`sfdx version` returned unexpected result", advice)
        return
    end
    local version_number = string.gsub(version_result.cliVersion,"sfdx%-cli/", "")
    if version_result.preamble then
        health.report_info(version_result.preamble)
    end
    if version_is_supported(version_number) then
        health.report_ok("Installed version is "..version_number.." (oldest supported version: "..oldest_supported_version..")")
    else
        health.report_error(
                string.format(
                        "%s %s %s %s",
                        "Outdated version",
                        version_number,
                        "found. Must have at least",
                        oldest_supported_version
                ), {
                    "run in shell: sfdx update"
        })
        return
    end
end

return {
    check_health = check_health
}
