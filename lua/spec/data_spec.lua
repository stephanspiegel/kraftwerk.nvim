local data = require("kraftwerk.data")

local command_received, callback_received

local function mock_sfdx(command, callback)
    command_received = command
    callback_received = callback
end

describe("data", function()
    describe("query()", function()
        it("should call sfdx with the correct command", function()
            data.query(2, 1, 1, "human", mock_sfdx)
            assert.is_true("command here", command_received)
        end)
    end)
end)
