local orchestrator = require('kraftwerk.orchestrator')

describe('orchestrator', function()

    describe('build_command_string', function()

        it('should build a command string without range or args', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {},
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query')", built_command)
        end)

        it('should build a command string with current-line range', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {
                    content = {
                        source = 'range_or_current_line'
                    }
                }
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! -range ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <range>, <line1>, <line2>)", built_command)
        end)

        it('should build a command string with current-file range', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {
                    content = {
                        source = 'range_or_current_file'
                    }
                },
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! -range=% ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <range>, <line1>, <line2>)", built_command)
        end)

        it('should build a command string with args', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {
                    args = {
                        name = 'format',
                        required = false
                    }
                },
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! -nargs=* ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <q-args>)", built_command)
        end)

        it('should build a command string with range and args', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {
                    args = {
                        name = 'format',
                        required = false
                    },
                    content = {
                        source = 'range_or_current_file'
                    }
                },
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! -range=% -nargs=* ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <range>, <line1>, <line2>, <q-args>)", built_command)
        end)

        it('should build a command string with bang', function()
            local command = {
                meta = {
                    module = 'data',
                    name = 'query',
                    command_name = 'ForceDataSoqlQuery'
                },
                expected_input = {
                    bang = true,
                    args = {
                        {
                            name = 'format',
                            required = false
                        }
                    },
                    content = {
                        source = 'range_or_current_file'
                    }
                },
            }
            local built_command = orchestrator.build_command_string(command)
            assert.are_equal("command! -range=% -bang -nargs=* ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <range>, <line1>, <line2>, <bang>, <q-args>)", built_command)
        end)

    end)

end)
