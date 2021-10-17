local quickfix = require('kraftwerk.util.quickfix')

describe('quickfix', function()

    describe('build_push_error_items', function()

        it('should build exptected list of error items', function()
            local input = { {
                    columnNumber = "17",
                    error = "Expecting ')' but was: 'dontPreserveTimeStamps' (17:17)",
                    filePath = "force-app/main/default/classes/Entity.cls",
                    fullName = "Entity",
                    lineNumber = "17",
                    problemType = "Error",
                    type = "ApexClass"
                }, {
                    columnNumber = "39",
                    error = "Expecting ';' but was: ',' (17:39)",
                    filePath = "force-app/main/default/classes/Entity.cls",
                    fullName = "Entity",
                    lineNumber = "17",
                    problemType = "Error",
                    type = "ApexClass"
            }}
            local expected = {
                {
                    col = "17",
                    filename = "force-app/main/default/classes/Entity.cls",
                    lnum = "17",
                    text = "Expecting ')' but was: 'dontPreserveTimeStamps' (17:17)",
                    type = "E"
                }, {
                    col = "39",
                    filename = "force-app/main/default/classes/Entity.cls",
                    lnum = "17",
                    text = "Expecting ';' but was: ',' (17:39)",
                    type = "E"
                }
            }
            local items = quickfix.build_push_error_items(input)
            assert.same(expected, items)
        end)

        it('should return empty list for empty list', function()
            assert.same({}, quickfix.build_push_error_items({}))
        end)

    end)

    describe('build_compile_error_items', function()

        it('should return expected error item', function()
            local input = {
                column = "8",
                compileProblem = "Unexpected token 'ent'.",
                compiled = false,
                exceptionMessage = "",
                exceptionStackTrace = "",
                line = "1",
                logs = "",
                success = false
            }
            local expected = {
                {
                    bufnr = '${current_buffer_number}',
                    col = '${selection_start_col_plus:7}',
                    lnum = '${selection_start_line_plus:0}',
                    module = "AnonymousBlock",
                    problemType = "E",
                    text = "Unexpected token 'ent'."
                }
            }
            assert.same(expected, quickfix.build_compile_error_items(input))
        end)

    end)

    describe('build_execute_anonymous_error_items', function()

        it('should return expected error items', function()
            local input = {
                column = "1",
                compileProblem = "",
                compiled = true,
                exceptionMessage = "System.NullPointerException: Attempt to de-reference a null object",
                exceptionStackTrace = "Class.Entity.move: line 20, column 1\nAnonymousBlock: line 2, column 1",
                line = "20",
                logs = "",
                success = false
            }
            local expected = {
                {
                    col = "1",
                    filename = '${file_path_to:Entity.cls}',
                    lnum = "20",
                    module = "Class.Entity.move",
                    text = "System.NullPointerException: Attempt to de-reference a null object"
                }, {
                    bufnr = '${current_buffer_number}',
                    col = "1",
                    lnum = "2",
                    module = "AnonymousBlock",
                    text = "    ... Continued"
                }
            }
            assert.same(expected, quickfix.build_execute_anonymous_error_items(input))
        end)

    end)

    describe('parse_lines_from_stack_trace', function()

        it('should parse newline-delimited stack trace', function()
            local stack_trace = [[
Some inconsequential line here
AcraliniException: No Noids allowed!

Class.World_StateTriggerHandler: line 6, column 1
Trigger.WorldState: line 2, column 1
Another inconsequential line
            ]]
            local expected =
            { {
                col = "1",
                filename = "${file_path_to:World_StateTriggerHandler.cls}",
                lnum = "6",
                module = "Class.World_StateTriggerHandler",
                text = "AcraliniException: No Noids allowed!"
              }, {
                col = "1",
                filename = "${file_path_to:WorldState.trigger}",
                lnum = "2",
                module = "Trigger.WorldState",
                text = "    ... Continued"
              } }
            assert.same(expected, quickfix.parse_lines_from_stack_trace(stack_trace))
        end)

        it('should parse inline stack trace', function()
            local stack_trace = "Class.GameEngineTest.itShouldAllowWorldStateNamedNoid|81 col 1| System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, WorldState: execution of BeforeInsert caused by: AcraliniException: No Noids allowed! Class.World_StateTriggerHandler: line 6, column 1 Trigger.WorldState: line 2, column 1: []"
            local expected =
            { {
                col = "1",
                filename = "${file_path_to:World_StateTriggerHandler.cls}",
                lnum = "6",
                module = "Class.World_StateTriggerHandler",
                text = "Class.GameEngineTest.itShouldAllowWorldStateNamedNoid|81 col 1| System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, WorldState: execution of BeforeInsert caused by: AcraliniException: No Noids allowed!"
              }, {
                col = "1",
                filename = "${file_path_to:WorldState.trigger}",
                lnum = "2",
                module = "Trigger.WorldState",
                text = "    ... Continued"
              } }
            assert.same(expected, quickfix.parse_lines_from_stack_trace(stack_trace))
        end)

    end)

end)
