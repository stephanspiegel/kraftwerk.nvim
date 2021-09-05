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

    describe('build_compile_error_item', function()

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
                bufnr = 1,
                col = 7,
                lnum = 0,
                module = "AnonymousBlock",
                problemType = "E",
                text = "Unexpected token 'ent'."
            }
            assert.same(expected, quickfix.build_compile_error_item(input))
        end)

    end)

    describe('build_execute_anonymous_error_item', function()

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
                    filename = "",
                    lnum = "20",
                    module = "Class.Entity.move",
                    text = "System.NullPointerException: Attempt to de-reference a null object"
                }, {
                    bufnr = 1,
                    col = "1",
                    lnum = "2",
                    module = "AnonymousBlock",
                    text = "... Continued"
                }
            }
            assert.same(expected, quickfix.build_execute_anonymous_error_item(input))
        end)

    end)

    describe('parse_stack_trace_line', function()

        it('should parse "Trigger" line', function()
            local line = 'Trigger.WorldState: line 12, column 1: error here'
            local expected = {
                module = 'Trigger.WorldState',
                class_name = 'WorldState',
                lnum = '12',
                col = '1'
            }
            assert.same(expected, quickfix.parse_stack_trace_line(line))

        end)

        it('should parse "Class" line', function()
            local line = 'Class.World_StateTriggerHandler: line 6, column 1'
            local expected = {
                module = 'Class.World_StateTriggerHandler',
                class_name = 'World_StateTriggerHandler',
                lnum = '6',
                col = '1'
            }
            assert.same(expected, quickfix.parse_stack_trace_line(line))
        end)

        it('should parse "AnonymousBlock" line', function()
            local line = 'AnonymousBlock: line 2, column 1: bloo'
            local expected = {
                module = 'AnonymousBlock',
                class_name = '',
                lnum = '2',
                col = '1'
            }
            assert.same(expected, quickfix.parse_stack_trace_line(line))
        end)

        it('should not match irrelevant line', function()
            local line = "This line won't match anything"
            local expected = {}
            assert.same(expected, quickfix.parse_stack_trace_line(line))
        end)

    end)

end)
