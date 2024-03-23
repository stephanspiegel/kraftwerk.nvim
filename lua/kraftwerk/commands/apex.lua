local completion = require('kraftwerk.util.completion')
local text = require('kraftwerk.util.text')
local functor = require('kraftwerk.util.functor')
local quickfix = require('kraftwerk.util.quickfix')
local english = require('kraftwerk.util.english')

local function complete_test_file_or_method(arg_lead, cmd_line, cursor_pos)
    if vim.fn.executable('rg') then
        local test_file_paths = vim.fn.system('rg "@isTest" --files-with-matches')
        local test_file_names = functor.map(function(test_file_path)
            return vim.fn.fnamemodify(test_file_path, ':t:r')
        end, text.split(test_file_paths, '\n'))
    return test_file_names
end
end

local expected_testrun_input = {
    args = {
        {
            name = 'file_or_method',
            required = false,
            complete = complete_test_file_or_method
        },
        {
            name = 'user',
            required = false,
            complete = completion.user
        }
    }
}

local function handle_failure(result)
    local io_data = { messages = {} }
    io_data.messages.err = { result.message }
    return io_data
end

local function build_testrun_command(input)
    local sfdx_command = { 'apex', 'run', 'test' }
    local test_article = vim.fn.expand('%:t:r:') -- default: current file
    if functor.has_key(input, 'file_or_method') and not text.is_blank(input.file_or_method) then
        test_article = input.file_or_method
    end
    table.insert(sfdx_command, '--tests=' .. test_article)
    local user_clause = ''
    if functor.has_key(input, 'user') then
        table.insert(sfdx_command, '--target-org=' .. input.user)
    end
    table.insert(sfdx_command, '--wait=30')
    local function testrun_callback(sfdx_result)
        local result = sfdx_result.result
        if not functor.has_key(result, 'summary') then
            return handle_failure(sfdx_result)
        else
            local io_data = { messages = {} }
            local summary = result.summary
            local test_run_message = english.pluralize('Ran {!number} {!noun} in ' .. summary.testTotalTime,
                summary.testsRan, 'test')
            if summary.outcome == 'Failed' then
                test_run_message = test_run_message .. english.pluralize(' -- {!number} {!noun} failed',
                    summary.failing, 'test')
                io_data.messages.err = test_run_message
                io_data.quickfix = quickfix.build_test_error_items(result)
            else
                if (summary.testsRan == 1) then
                    test_run_message = test_run_message .. ' -- it passed!'
                else
                    test_run_message = test_run_message .. ' -- they all passed!'
                end
                io_data.messages.info = { test_run_message }
            end
            return io_data
        end
    end
    return sfdx_command, testrun_callback
end

local testrun_command = {
    meta = {
        module = 'apex',
        name = 'testrun',
        command_name = 'ForceApexTestRun'
    },
    expected_input = expected_testrun_input,
    build_command = build_testrun_command,
    sfdx_call = 'call_sfdx'
}

local expected_execute_input = {
    args = {
        {
            name = 'user',
            required = false,
            complete = completion.user
        }
    },
    content = {
        source = 'range_or_current_file',
        format = 'temp_file',
        required = true
    }
}

local function execute_callback(result)
    local io_data = {
        messages = {}
    }
    local run_result = functor.has_key(result, 'result') and result.result or result.data
    if run_result == nil then
        return handle_failure(result)
    end
    if run_result.success then
        io_data.messages.info = {'Executed anonymous code successfully'}
        local logs = text.split(run_result.logs, '\n')
        io_data.result_buffer = {
            title = '__Apex_Result__',
            content = logs,
            file_type = 'apexlog'
        }
        return io_data
    end
    if not functor.has_key(run_result, 'compiled') then
        return handle_failure(result)
    end
    if not run_result.compiled then
        io_data.quickfix = quickfix.build_compile_error_items(run_result)
        io_data.messages.err = {'Error compiling anonymous code'}
        return io_data
    end
    io_data.quickfix = quickfix.build_execute_anonymous_error_items(run_result)
    local logs = text.split(run_result.logs, '\n')
    io_data.result_buffer = {
        title = '__Apex_Result__',
        content = logs,
        file_type = 'apexlog'
    }
    io_data.messages.err = {'Error executing anonymous code'}
    return io_data
end

local function build_execute_command(input)
    local sfdx_command_parts = { 'apex', 'run' }
    sfdx_command_parts = functor.append(sfdx_command_parts, '--file='..input.temp_file_path)
    if functor.has_key(input, 'user') then
        sfdx_command_parts = functor.append(sfdx_command_parts, '--target-org=' .. input.user)
    end
    return sfdx_command_parts, execute_callback
end

local execute_command = {
    meta = {
        module = 'apex',
        name = 'execute',
        command_name = 'ForceApexExecute'
    },
    expected_input = expected_execute_input,
    build_command = build_execute_command,
    sfdx_call = 'call_sfdx'

}

local expected_unstack_input = {
    content = {
        source = 'range_or_current_line',
        format = 'text',
        required = true
    }
}

local function build_unstack_command(input)
    local lines = input.content
    local function unstack_callback()
        local quickfix_entries = quickfix.parse_lines_from_stack_trace(lines)
        functor.map(function(entry)
            -- in an "unstack" context we don't know which file AnonymousBlock refers to, so remove the reference to the current buffer
            if functor.has_key(entry, 'bufnr') and entry['bufnr'] == '${current_buffer_number}' then
                entry['bufnr'] = nil
            end
        end, quickfix_entries)
        local io_data = {
            quickfix = quickfix_entries
        }
        return io_data
    end
    return '', unstack_callback
end

local unstack_comand = {
    meta = {
        module = 'apex',
        name = 'unstack',
        command_name = 'ForceApexUnstack'
    },
    expected_input = expected_unstack_input,
    build_command = build_unstack_command,
    sfdx_call = 'none'
}

return {
    testrun = testrun_command,
    complete_test_file_or_method = complete_test_file_or_method,
    execute = execute_command,
    unstack = unstack_comand,
}
