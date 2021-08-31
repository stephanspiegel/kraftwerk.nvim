local io_handler = require('kraftwerk.io_handler')
local sfdx_runner = require('kraftwerk.sfdx_runner')
local functor = require('kraftwerk.util.functor')
local text = require('kraftwerk.util.text')

local call = function(module_name, command, ...)
    local command_args = {...}
    local range, args
    local bang = false
    local command_module = require('kraftwerk.commands.'..module_name)[command]
    local expected_input = command_module.expected_input
    if functor.contains_key(expected_input, 'bang') and expected_input.bang then
        bang = command_args[1] == '!'
        command_args = functor.slice(command_args, 2)
    end
    if #command_args == 4 then -- range command, first 3 arguments are about the range
        range = functor.slice(command_args, 1, 3)
        args = vim.split(command_args[4], '%s+')
    else -- not a range command, any args are user-entered
        range = {}
        args = {}
        if #command_args > 0 then
            args = vim.split(command_args[1], '%s+')
        end
    end
    local input_result = io_handler.gather_input(expected_input, bang, range, args)
    if functor.contains_key(input_result, 'messages') then
        local messages = input_result.messages
        io_handler.output({ messages = messages })
        if functor.contains_key(messages, 'err') then
            return
        end
    end
    local sfdx_command, command_callback = command_module.build_command(input_result)
    local orchestrator_callback = function(sfdx_result)
        local command_output = command_callback(sfdx_result)
        io_handler.output(command_output)
    end
    local sfdx_call = command_module.sfdx_call
    sfdx_runner[sfdx_call](sfdx_command, orchestrator_callback)
end

local function build_command_string(command_definition, completion_function_name)
    local command_parts = {'command!'}
    local module_name = command_definition.meta.module
    local command = command_definition.meta.name
    local expected_input = command_definition.expected_input
    local args = { "'"..module_name.."'", "'"..command.."'"}
    if functor.contains_key(expected_input, 'bang') then
        if expected_input.bang == true then
            table.insert(command_parts, '-bang')
            table.insert(args, '<q-bang>')
        end
    end
    if functor.contains_key(expected_input, 'content') then
        local content_source = expected_input.content.source
        if content_source == 'range_or_current_line' then
            table.insert(command_parts, '-range')
            table.insert(args, '<range>')
            table.insert(args, '<line1>')
            table.insert(args, '<line2>')
        elseif content_source == 'range_or_current_file' then
            table.insert(command_parts, '-range=%')
            table.insert(args, '<range>')
            table.insert(args, '<line1>')
            table.insert(args, '<line2>')
        end
    end
    if functor.contains_key(expected_input, 'args') then
        table.insert(command_parts, '-nargs=*')
        if completion_function_name ~= nil then
            table.insert(command_parts, "-complete=custom,v:lua."..completion_function_name)
        end
        table.insert(args, '<q-args>')
    end
    table.insert(command_parts, command_definition.meta.command_name)
    local args_string = '(' .. table.concat(args, ', ') .. ')'
    table.insert(command_parts, "lua require'kraftwerk.orchestrator'.call"..args_string)
    return table.concat(command_parts, ' ')
end

local function register_completion(command_definition)
    if functor.is_null_or_empty(command_definition.expected_input)
        or functor.is_null_or_empty(command_definition.expected_input.args) then
        return ''
    end
    local module_name = command_definition.meta.module
    local command = command_definition.meta.name
    local completion_function_name = module_name .. '_' .. command
    local completion_function_full_name = 'kraftwerk.command_completion.' .. completion_function_name
    local completion_functions = {}
    for _, arg in ipairs(command_definition.expected_input.args) do
        if functor.contains_key(arg, 'valid_values') then
            table.insert(completion_functions, function()
                return arg.valid_values
            end)
        elseif functor.contains_key(arg, 'complete') then
            table.insert(completion_functions, arg.complete)
        else
            table.insert(completion_functions, function() return {} end)
        end
    end

    _G.kraftwerk.command_completion[completion_function_name] = function(arg_lead, cmd_line, cursor_pos)
        -- find which argument the cursor is on
        local cmd_line_to_cursor = string.sub(cmd_line, 1, cursor_pos)
        local cmd_line_words = text.split(cmd_line_to_cursor)
        local argument_pos = #cmd_line_words
        local candidates = completion_functions[argument_pos](arg_lead, cmd_line, cursor_pos)
        return table.concat(candidates, '\n')
    end
    return completion_function_full_name
end

local function get_command_definition(module_name, name)
    local command_definition = require('kraftwerk.commands.'..module_name)[name]
    return command_definition
end

local function register(module_name, command)
    local command_definition = get_command_definition(module_name, command)
    local completion_function_name = register_completion(command_definition)
    local command_string = build_command_string(command_definition, completion_function_name)
    vim.cmd(command_string)
end

return {
    call = call,
    register = register,
    build_command_string = build_command_string
}
