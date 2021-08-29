local list = require("kraftwerk.list")
local buffer = require("kraftwerk.buffer")

describe("list", function()
    describe("contains()", function()
        it("should return 'true' if the table contains the element", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_true(list.contains(ghosts, "Susie Salmon"))
        end)
        it("should return 'false' if the table doesn't contain the element", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_false(list.contains(ghosts, "Controversy Jackson"))
        end)
        it("should return 'false' if the test value is nil", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_false(list.contains(ghosts, nil))
        end)
        it("should return 'false' if the table is empty", function()
            local ghosts = {}
            assert.is_false(list.contains(ghosts, "Miss Jessel"))
        end)
        it("should return 'false' if the table is nil", function()
            local ghosts = nil
            assert.is_false(list.contains(ghosts, "Miss Jessel"))
        end)
    end)

    describe("contains_key()", function()
        it("should return 'true' if the table contains the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_true(list.contains_key(organisms, "plant"))
        end)
        it("should return 'false' if the table doesn't contain the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(list.contains_key(organisms, "protist"))
        end)
        it("should return 'false' if the test value is nil", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(list.contains_key(organisms, nil))
        end)
        it("should return 'false' if the table is empty", function()
            local organisms = {}
            assert.is_false(list.contains_key(organisms, "plant"))
        end)
        it("should return 'false' if the table is nil", function()
            local organisms = nil
            assert.is_false(list.contains_key(organisms, "plant"))
        end)
    end)

    describe("contains_value()", function()
        it("should return 'true' if the table contains the value", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_true(list.contains_value(organisms, "Paris japonica"))
        end)
        it("should return 'false' if the table doesn't contain the value", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(list.contains_value(organisms, "Ursus arctos"))
        end)
        it("should return 'false' if the test value is nil", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(list.contains_value(organisms, nil))
        end)
        it("should return 'false' if the table is empty", function()
            local organisms = {}
            assert.is_false(list.contains_value(organisms, "Paris japonica"))
        end)
        it("should return 'false' if the table is nil", function()
            local organisms = nil
            assert.is_false(list.contains_value(organisms, "Paris japonica"))
        end)
    end)

    local function setUpBuffer(input, filetype)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
        vim.api.nvim_command("buffer " .. buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(input, "\n"))
        return buf
    end

    describe("get_visual_selection()", function()
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

    describe("slice", function() 

        it("should return specified part of table", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = list.slice(source_table, 2, 3)
            assert.same({'b', 'c'}, result_table)
        end)

        it("should return entire table", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = list.slice(source_table, 1, #source_table)
            assert.same({'a', 'b', 'c', 'd'}, result_table)
        end)

        it("should return rest of table if no end_index given", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = list.slice(source_table, 3)
            assert.same({'c', 'd'}, result_table)
        end)

        it("should error if negative start_index given", function()
            local source_table = { 'a' }
            assert.has.errors(function() list.slice(source_table, -1) end)
        end)

        it("should error if negative end_index given", function()
            local source_table = { 'a' }
            assert.has.errors(function() list.slice(source_table, 1, -1) end)
        end)

        it("should error if start_index is less than end_index", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() list.slice(source_table, 2, 1) end)
        end)

        it("should error if start_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() list.slice(source_table, 4) end)
        end)

        it("should error if end_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() list.slice(source_table, 2, 4) end)
        end)

    end)

end)
