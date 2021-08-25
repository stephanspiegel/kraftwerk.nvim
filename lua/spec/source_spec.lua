local source = require('kraftwerk.source')
local sfdx_runner = require('kraftwerk.sfdx_runner')

describe("source", function()
    describe("push", function()
        describe("build_command", function()
            it("should build the command correctly", function()
                local sfdx_command, _ = source.push.build_command()
                assert.are_equal('force:source:push', sfdx_command)
            end)
        end)
        describe("callback", function()

            it("should warn if nothing to push", function()
                local _, callback = source.push.build_command()
                local result = {
                    status = 0,
                    result = {
                        pushedSource = {}
                    }
                }
                local expected = {
                    messages = {
                        warn = { 'Nothing to push.' },
                    }
                }
                assert.same(expected, callback(result))
            end)

            it("should show any errors returned", function()
                local _, callback = source.push.build_command()
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
                local _, callback = source.push.build_command()
                local result = sfdx_runner.jsondecode [[
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
                local _, callback = source.push.build_command()
                local result = sfdx_runner.jsondecode [[
{
  "status": 0,
  "result": {
    "pushedSource": [
      {
        "state": "Changed",
        "fullName": "GameEngine",
        "type": "ApexClass",
        "filePath": "force-app/main/default/classes/GameEngine.cls"
      },
      {
        "state": "Changed",
        "fullName": "Entity__c.NPC",
        "type": "RecordType",
        "filePath": "force-app/main/default/objects/Entity__c/recordTypes/NPC.recordTyp e-meta.xml"
      }
    ]
  }
}
                ]]
                local expected = {
                    messages = {
                        info = {
                            'Changed force-app/main/default/classes/GameEngine.cls',
                            'Changed force-app/main/default/objects/Entity__c/recordTypes/NPC.recordTyp e-meta.xml',
                            'Push succeeded'
                        }
                    }
                }
                assert.same(expected, callback(result))
            end)

        end)
    end)
end)
