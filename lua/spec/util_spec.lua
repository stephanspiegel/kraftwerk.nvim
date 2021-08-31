local buffer = require("kraftwerk.util.buffer")

describe('buffer', function()

    describe("get_visual_selection()", function()

        local function setUpBuffer(input, filetype)
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
            vim.api.nvim_command("buffer " .. buf)
            vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(input, "\n"))
            return buf
        end

        it("should return the single-line visual selection in visual mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal 3Gwwwvwe]]
            assert.are_equal("seine Geister", buffer.get_visual_selection())
            -- Leave visual mode for next test
            vim.cmd [[normal :esc<CR>]]
        end)

        it("should return the multi-line visual selection in visual mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal wwwvj0e]]
            assert.are_equal("Hexenmeister\nSich", buffer.get_visual_selection())
            -- Leave visual mode for next test
            vim.cmd [[normal :esc<CR>]]
        end)

        it("should return the multi-line visual selection in visual line mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal jVj]]
            assert.are_equal("Sich doch einmal wegbegeben!\nUnd nun sollen seine Geister", buffer.get_visual_selection())
            -- Leave visual mode for next test
            vim.cmd [[normal :esc<CR>]]
        end)

        it("should return the multi-line visual selection in visual line mode when selected from the end", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal 4Gevbb]]
            assert.are_equal("Geister\nAuch", buffer.get_visual_selection())
            -- Leave visual mode for next test
            vim.cmd [[normal :esc<CR>]]
        end)

        it("should return the single-line visual selection after leaving visual mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal 3Gwvee]]
            vim.cmd [[normal :esc<CR>]]
            assert.are_equal("nun sollen", buffer.get_visual_selection())
        end)

        it("should return the multi-line visual selection after leaving visual mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal wwwvj0e]]
            vim.cmd [[normal :esc<CR>]]
            assert.are_equal("Hexenmeister\nSich", buffer.get_visual_selection())
        end)

        it("should return the multi-line line-wise visual selection after leaving visual line mode", function()
            local input = [[
Hat der alte Hexenmeister
Sich doch einmal wegbegeben!
Und nun sollen seine Geister
Auch nach meinem Willen leben.
            ]]
            local bufnr = setUpBuffer(input, "txt")
            vim.api.nvim_command [[normal jVj]]
            vim.cmd [[normal :esc<CR>]]
            assert.are_equal("Sich doch einmal wegbegeben!\nUnd nun sollen seine Geister", buffer.get_visual_selection())
        end)

    end)

end)
