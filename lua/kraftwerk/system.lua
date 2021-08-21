local sfdx_runner = require("kraftwerk.sfdx_runner")

local oldest_supported_version = "7.110.0"

local function sfdx_is_installed()
    local sfdx_executable = 'sfdx'
    if vim.g.kraftwerk_sfdx_executable ~= null then
        sfdx_executable = vim.g.kraftwerk_sfdx_executable
    end
    local is_installed = vim.fn.executable(sfdx_executable)
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

local function report_ok(message)
    vim.call("health#report_ok", message)
end

local function report_error(message, suggestions)
    vim.call("health#report_error", message, suggestions)
end

local function check_health()
    vim.call("health#report_start", "Check sfdx-cli")
    if sfdx_is_installed() then
        report_ok("Found sfdx executable")
    else
        report_error("Couldn't find sfdx", {
                "run in shell: npm install sfdx-cli --global",
                "see install instructions: https://developer.salesforce.com/tools/sfdxcli",
                "make sure sfdx is in your path environment variable",
                "(optional): specify sfdx-cli executable along with full path in g:kraftwerk_sfdx_executable"
            })
        return
    end
    local version_result = sfdx_runner.call_sfdx_sync('version')
    local version_number = string.gsub(version_result.cliVersion,"sfdx%-cli/", "")
    if version_is_supported(version_number) then
        report_ok("Up to date")
    else
        report_error("Outdated version " .. version_number .." found. Must have at least " .. oldest_supported_version, {
                "run in shell: sfdx update"
        })
        return
    end
end

return {
    check_health = check_health
}
