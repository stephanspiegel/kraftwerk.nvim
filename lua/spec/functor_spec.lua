local functor = require('kraftwerk.util.functor')

describe("functor", function()

    describe("contains()", function()

        it("should return 'true' if the table contains the element", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_true(functor.contains(ghosts, "Susie Salmon"))
        end)

        it("should return 'false' if the table doesn't contain the element", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_false(functor.contains(ghosts, "Controversy Jackson"))
        end)

        it("should return 'false' if the test value is nil", function()
            local ghosts = {"Miss Jessel", "Susie Salmon", "Green Lady"}
            assert.is_false(functor.contains(ghosts, nil))
        end)

        it("should return 'false' if the table is empty", function()
            local ghosts = {}
            assert.is_false(functor.contains(ghosts, "Miss Jessel"))
        end)

        it("should return 'false' if the table is nil", function()
            local ghosts = nil
            assert.is_false(functor.contains(ghosts, "Miss Jessel"))
        end)

    end)

    describe("contains_key()", function()

        it("should return 'true' if the table contains the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_true(functor.contains_key(organisms, "plant"))
        end)

        it("should return 'false' if the table doesn't contain the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.contains_key(organisms, "protist"))
        end)

        it("should return 'false' if the test value is nil", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.contains_key(organisms, nil))
        end)

        it("should return 'false' if the table is empty", function()
            local organisms = {}
            assert.is_false(functor.contains_key(organisms, "plant"))
        end)

        it("should return 'false' if the table is nil", function()
            local organisms = nil
            assert.is_false(functor.contains_key(organisms, "plant"))
        end)

    end)

    describe("contains_value()", function()

        it("should return 'true' if the table contains the value", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_true(functor.contains_value(organisms, "Paris japonica"))
        end)

        it("should return 'false' if the table doesn't contain the value", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.contains_value(organisms, "Ursus arctos"))
        end)

        it("should return 'false' if the test value is nil", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.contains_value(organisms, nil))
        end)

        it("should return 'false' if the table is empty", function()
            local organisms = {}
            assert.is_false(functor.contains_value(organisms, "Paris japonica"))
        end)

        it("should return 'false' if the table is nil", function()
            local organisms = nil
            assert.is_false(functor.contains_value(organisms, "Paris japonica"))
        end)

    end)

    describe("slice", function()

        it("should return specified part of table", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = functor.slice(source_table, 2, 3)
            assert.same({'b', 'c'}, result_table)
        end)

        it("should return entire table", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = functor.slice(source_table, 1, #source_table)
            assert.same({'a', 'b', 'c', 'd'}, result_table)
        end)

        it("should return rest of table if no end_index given", function()
            local source_table = { 'a', 'b', 'c', 'd' }
            local result_table = functor.slice(source_table, 3)
            assert.same({'c', 'd'}, result_table)
        end)

        it("should error if negative start_index given", function()
            local source_table = { 'a' }
            assert.has.errors(function() functor.slice(source_table, -1) end)
        end)

        it("should error if negative end_index given", function()
            local source_table = { 'a' }
            assert.has.errors(function() functor.slice(source_table, 1, -1) end)
        end)

        it("should error if start_index is less than end_index", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() functor.slice(source_table, 2, 1) end)
        end)

        it("should error if start_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() functor.slice(source_table, 4) end)
        end)

        it("should error if end_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.has.errors(function() functor.slice(source_table, 2, 4) end)
        end)

    end)

    describe('map', function()

        it("should apply passed in function to each element", function()
            local list = {2,3,4}
            local function double(x) return x*2 end
            assert.same({4,6,8}, functor.map(double, list))
        end)

        it('should return empty list for empty list passed in', function()
            local list = {}
            local function double(x) return x*2 end
            assert.same({}, functor.map(double, list))
        end)

        it('should curry function if no table passed in', function()
            local list = {2,3,4}
            local function double(x) return x*2 end
            local curried_function = functor.map(double)
            assert.same({4,6,8}, curried_function(list))
        end)

    end)

end)
