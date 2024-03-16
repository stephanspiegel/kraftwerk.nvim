local source = require('kraftwerk.commands.source')
local json = require('kraftwerk.util.json')

describe("source", function()

    describe("push", function()

        describe("build_command", function()

            it("should build the command correctly", function()
                local input = {}
                local sfdx_command, _ = source.push.build_command(input)
                assert.are.same({'project', 'deploy', 'start'}, sfdx_command)
            end)

        end)

        describe("callback", function()

            it("should warn if nothing to push", function()
                local input = {}
                local _, callback = source.push.build_command(input)
                local result = {
                    status = 0,
                    result = {
                        status = 'Nothing to deploy'
                    }
                }
                local expected = {
                    messages = {
                        warn = { 'Nothing to deploy' },
                    }
                }
                assert.same(expected, callback(result))
            end)

            it("should show any errors returned", function()
                local input = {}
                local _, callback = source.push.build_command(input)
                local result = {
                    status = 1,
                    name = "RequiresProjectError",
                    message = "This command is required to run from within an SFDX project.",
                    exitCode = 1,
                    commandName = "SourcePushCommand",
                    warnings = {}
                }
                local expected = {
                    messages = {
                        err = { 'SourcePushCommand: This command is required to run from within an SFDX project.'}
                    }
                }
                assert.same(expected, callback(result))
            end)

            it("should show compile errors in quickfix", function()
                local input = {}
                local _, callback = source.push.build_command(input)
                local result = json.decode [[
{
  "status": 1,
  "result": [
    {
      "columnNumber": "5",
      "lineNumber": "12",
      "error": "Annotation does not exist: AuraEnableds (12:5)",
      "fullName": "GameEngine",
      "type": "ApexClass",
      "filePath": "force-app/main/default/classes/GameEngine.cls",
      "problemType": "Error"
    }
  ],
  "name": "DeployFailed",
  "message": "Push failed.",
  "exitCode": 1,
  "actions": [],
  "commandName": "SourcePushCommand",
  "data": [
    {
      "columnNumber": "5",
      "lineNumber": "12",
      "error": "Annotation does not exist: AuraEnableds (12:5)",
      "fullName": "GameEngine",
      "type": "ApexClass",
      "filePath": "force-app/main/default/classes/GameEngine.cls",
      "problemType": "Error"
    }
  ],
  "stack": "DeployFailed etc.",
  "warnings": []
}
                ]]
                local expected = {
                    messages = {
                        err = { 'SourcePushCommand: Push failed.' },
                    },
                    quickfix = {
                        {
                            col = '5',
                            filename = 'force-app/main/default/classes/GameEngine.cls',
                            lnum = '12',
                            text = 'Annotation does not exist: AuraEnableds (12:5)',
                            type = 'E'
                        }
                    }
                }
                assert.same(expected, callback(result))
            end)

            it("should show pushed metadata when successful", function()
                local input = {}
                local _, callback = source.push.build_command(input)
                local result = json.decode [[
{
  "status": 0,
  "result": {
    "checkOnly": false,
    "completedDate": "2024-03-16T13:03:25.000Z",
    "createdBy": "0057e00000WjbUN",
    "createdByName": "User User",
    "createdDate": "2024-03-16T13:03:23.000Z",
    "details": {
      "componentSuccesses": [
        {
          "changed": true,
          "componentType": "ApexClass",
          "created": false,
          "createdDate": "2024-03-16T13:03:24.000Z",
          "deleted": false,
          "fileName": "classes/AlmanacResolver.cls",
          "fullName": "AlmanacResolver",
          "id": "01p7e00000LDE1ZAAX",
          "success": true
        }
      ],
      "runTestResult": {
        "numFailures": 0,
        "numTestsRun": 0,
        "totalTime": 0,
        "codeCoverage": [],
        "codeCoverageWarnings": [],
        "failures": [],
        "flowCoverage": [],
        "flowCoverageWarnings": [],
        "successes": []
      },
      "componentFailures": []
    },
    "done": true,
    "id": "0Af7e00001lUlkKCAS",
    "ignoreWarnings": false,
    "lastModifiedDate": "2024-03-16T13:03:25.000Z",
    "numberComponentErrors": 0,
    "numberComponentsDeployed": 1,
    "numberComponentsTotal": 1,
    "numberTestErrors": 0,
    "numberTestsCompleted": 0,
    "numberTestsTotal": 0,
    "rollbackOnError": true,
    "runTestsEnabled": false,
    "startDate": "2024-03-16T13:03:24.000Z",
    "status": "Succeeded",
    "success": true,
    "files": [
      {
        "fullName": "AlmanacResolver",
        "type": "ApexClass",
        "state": "Changed",
        "filePath": "/home/stephan/Projects/salesforce/Apex_AdventOfCode2023/force-app/main/default/classes/AlmanacResolver.cls"
      }
    ]
  },
  "warnings": []
}
                ]]
                local expected = {
                    messages = {
                        info = {
                            'Deploy succeeded',
                            'Changed AlmanacResolver'
                        }
                    }
                }
                assert.same(expected, callback(result))
            end)

        end)
    end)
end)
