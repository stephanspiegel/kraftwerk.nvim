local data = require("kraftwerk.data")

local command_received, callback_received

local function mock_sfdx(command, callback)
    command_received = command
    callback_received = callback
end

describe("data", function()
    describe("build_query_string()", function()

        it("should call sfdx with the correct command", function()
            local query_string = 'SELECT Id FROM User'
            local sfdx_command = data.build_query_command(query_string, "csv")
            local expected = 'force:data:soql:query --query "SELECT Id FROM User"  --resultformat=csv'
            assert.are_equal(expected, sfdx_command)
        end)

        it("should error when called with unknown format", function()
            local query_string = 'SELECT Id FROM User'
            local ok, error_message = pcall(data.build_query_command, query_string, "fizzbuzz")
            assert.is_false(ok)
            assert.are_equal("Unknown query result format: fizzbuzz", error_message)
        end)

    end)
end)
