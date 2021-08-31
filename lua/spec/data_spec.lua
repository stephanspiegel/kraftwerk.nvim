local data = require("kraftwerk.commands.data")

describe("data", function()

    describe("query", function()

        describe("build_command", function()

            it("should build the command correctly", function()
                local build_command,_ = data.query.build_command
                local input = {
                    content = 'SELECT Id FROM User',
                    format = 'csv'
                }
                local expected = 'force:data:soql:query --query "SELECT Id FROM User"  --resultformat=csv'
                assert.same(expected, build_command(input))
            end)
        end)

        describe("callback", function()


            it("should specify a result buffer correctly for a sucessful result", function()
                local input = {
                    content = 'SELECT Id FROM User',
                    format = 'csv'
                }
                local _, callback = data.query.build_command(input)
                local result = [[
Id,Name
005J000000CFOxoIAH,User User
005J000000CFOxtIAH,Integration User
                ]]
                local expected = {
                    result_buffer = {
                        content = result,
                        file_type = 'csv',
                        title = '__Query_Result__'
                    }
                }
                assert.same(expected, callback(result))
            end)

        end)

    end)

end)
