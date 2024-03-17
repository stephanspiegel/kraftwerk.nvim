local apex = require("kraftwerk.commands.apex")
local json = require("kraftwerk.util.json")

describe('apex', function()

    describe('testrun', function ()

        describe('build_command', function ()
            it('builds the command', function ()
                local input = {
                    file_or_method = 'TestClass'
                }
                local build_command,_ = apex.testrun.build_command
                local expected =
                {
                    'apex',
                    'run',
                    'test',
                    '--tests=TestClass',
                    '--wait=30',
                }
                assert.are.same(expected, build_command(input))
            end)

        end)

        describe('callback', function ()

            it('treats missing "summary" field as failure', function ()
                local input = {
                    file_or_method = 'TestClass'
                }
                local _, callback = apex.testrun.build_command(input)
                -- this happens when the configured alias points to a scratch-org that doesn't exist
                local result = json.decode [[
                    {
                      "code": 1,
                      "context": "Test",
                      "commandName": "Test",
                      "message": "HTTP response contains html content.\nCheck that the org exists and can be reached.\nSee error.content for the full html response.",
                      "name": "ERROR_HTTP_420",
                      "status": 1,
                      "stack": "ERROR_HTTP_420: HTTP response contains html content.\n ...",
                      "exitCode": 1,
                      "warnings": []
                    }
                ]]
                local expected = {
                    messages = {
                        err = {
                            [[HTTP response contains html content.
Check that the org exists and can be reached.
See error.content for the full html response.]]
                        }
                    }
                }
                assert.are.same(expected, callback(result))
            end)

            it('builds quickfix items for failed unit tests', function ()
                local input = {
                    file_or_method = 'TestClass'
                }
                local _, callback = apex.testrun.build_command(input)
                local result = json.decode [[{
  "status": 100,
  "result": {
    "summary": {
      "outcome": "Failed",
      "testsRan": 1,
      "passing": 0,
      "failing": 1,
      "skipped": 0,
      "passRate": "0%",
      "failRate": "100%",
      "testStartTime": "2024-03-17T19:23:01.000Z",
      "testExecutionTime": "13 ms",
      "testTotalTime": "13 ms",
      "commandTime": "349 ms",
      "hostname": "https://ability-dream-4376-dev-ed.scratch.my.salesforce.com",
      "orgId": "00D8G000000m7HSUAY",
      "username": "test-vmx1huihsdsj@example.com",
      "testRunId": "7078G00001s4oQP",
      "userId": "0058G000006ixvhQAA"
    },
    "tests": [
      {
        "Id": "07M8G00000DK7IEUA1",
        "QueueItemId": "7098G000001epD4QAI",
        "StackTrace": "Class.AlmanacResolver.parseSeedsFromInput: line 31, column 1\nClass.AlmanacResolver.<init>: line 10, column 1\nClass.AlmanacResolverTest.parsesSeeds: line 43, column 1",
        "Message": "System.TypeException: Invalid integer: abc",
        "AsyncApexJobId": "7078G00001s4oQPQAY",
        "MethodName": "parsesSeeds",
        "Outcome": "Fail",
        "ApexClass": {
          "Id": "01p8G00000OuqouQAB",
          "Name": "AlmanacResolverTest",
          "NamespacePrefix": null
        },
        "RunTime": 13,
        "FullName": "AlmanacResolverTest.parsesSeeds"
      }
    ]
  },
  "warnings": []
}]]

                local expected = {
                    messages = {
                        err = 'Ran one test in 13 ms -- one test failed',
                    },
                    quickfix = {
                        {
                            col = '1',
                            filename = '${file_path_to:AlmanacResolver.cls}',
                            lnum = '31',
                            module = 'Class.AlmanacResolver.parseSeedsFromInput',
                            text = 'System.TypeException: Invalid integer: abc',
                        },
                        {
                            col = '1',
                            filename = '${file_path_to:AlmanacResolver.cls}',
                            lnum = '10',
                            module = 'Class.AlmanacResolver.<init>',
                            text = '    ... Continued',
                        },
                        {
                            col = '1',
                            filename = '${file_path_to:AlmanacResolverTest.cls}',
                            lnum = '43',
                            module = 'Class.AlmanacResolverTest.parsesSeeds',
                            text = '    ... Continued',
                        }
                    }
                }
                assert.are.same(expected, callback(result))

            end)

            it('shows success message when tests succeed', function ()
                local input = {
                    file_or_method = 'TestClass'
                }
                local _, callback = apex.testrun.build_command(input)
                local result = json.decode [[
{
  "status": 0,
  "result": {
    "summary": {
      "outcome": "Passed",
      "testsRan": 3,
      "passing": 3,
      "failing": 0,
      "skipped": 0,
      "passRate": "100%",
      "failRate": "0%",
      "testStartTime": "2024-03-17T19:42:32.000Z",
      "testExecutionTime": "39 ms",
      "testTotalTime": "39 ms",
      "commandTime": "164 ms",
      "hostname": "https://ability-dream-4376-dev-ed.scratch.my.salesforce.com",
      "orgId": "00D8G000000m7HSUAY",
      "username": "test-vmx1huihsdsj@example.com",
      "testRunId": "7078G00001s4opE",
      "userId": "0058G000006ixvhQAA"
    },
    "tests": [
      {
        "Id": "07M8G00000DK7JlUAL",
        "QueueItemId": "7098G000001epDEQAY",
        "StackTrace": null,
        "Message": null,
        "AsyncApexJobId": "7078G00001s4opEQAQ",
        "MethodName": "parserReturnsExpectedNumber",
        "Outcome": "Pass",
        "ApexClass": {
          "Id": "01p8G00000OuqoxQAB",
          "Name": "CalibrationValueParserTest",
          "NamespacePrefix": null
        },
        "RunTime": 22,
        "FullName": "CalibrationValueParserTest.parserReturnsExpectedNumber"
      },
      {
        "Id": "07M8G00000DK7JmUAL",
        "QueueItemId": "7098G000001epDEQAY",
        "StackTrace": null,
        "Message": null,
        "AsyncApexJobId": "7078G00001s4opEQAQ",
        "MethodName": "spelledOutNumbersCalculatesCorrectLineItem",
        "Outcome": "Pass",
        "ApexClass": {
          "Id": "01p8G00000OuqoxQAB",
          "Name": "CalibrationValueParserTest",
          "NamespacePrefix": null
        },
        "RunTime": 9,
        "FullName": "CalibrationValueParserTest.spelledOutNumbersCalculatesCorrectLineItem"
      },
      {
        "Id": "07M8G00000DK7JnUAL",
        "QueueItemId": "7098G000001epDEQAY",
        "StackTrace": null,
        "Message": null,
        "AsyncApexJobId": "7078G00001s4opEQAQ",
        "MethodName": "spelledOutNumbersCalculatesCorrectTotal",
        "Outcome": "Pass",
        "ApexClass": {
          "Id": "01p8G00000OuqoxQAB",
          "Name": "CalibrationValueParserTest",
          "NamespacePrefix": null
        },
        "RunTime": 8,
        "FullName": "CalibrationValueParserTest.spelledOutNumbersCalculatesCorrectTotal"
      }
    ]
  },
  "warnings": []
}
]]
                local expected = {
                    messages = {
                        info = { 'Ran three tests in 39 ms -- they all passed!' }
                    }
                }
                assert.are.same(expected, callback(result))
            end)

        end)

    end)

end)


