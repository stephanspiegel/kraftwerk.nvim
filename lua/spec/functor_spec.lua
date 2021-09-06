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

    describe("has_key()", function()

        it("should return 'true' if the table contains the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_true(functor.has_key(organisms, "plant"))
        end)

        it("should return 'false' if the table doesn't contain the key", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.has_key(organisms, "protist"))
        end)

        it("should return 'false' if the test value is nil", function()
            local organisms = {
                animal = "Neoceratodus forsteri",
                plant = "Paris japonica",
                fungus = "Gymnosporangium confusum"
            }
            assert.is_false(functor.has_key(organisms, nil))
        end)

        it("should return 'false' if the table is empty", function()
            local organisms = {}
            assert.is_false(functor.has_key(organisms, "plant"))
        end)

        it("should return 'false' if the table is nil", function()
            local organisms = nil
            assert.is_false(functor.has_key(organisms, "plant"))
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

        it("should count from end of list if start index is negative", function()
            local source_table = { 'a', 'b', 'c', 'd', 'e' }
            assert.same({'d', 'e'}, functor.slice(source_table, -2))
        end)

        it("should count from end of list if end index is negative", function()
            local source_table = { 'a', 'b', 'c', 'd', 'e' }
            assert.same({'c', 'd'}, functor.slice(source_table, 3, -2))
        end)

        it("should swap start and end indexes if start index is larger than end index", function()
            local source_table = { 'a', 'b', 'c', 'd', 'e' }
            assert.same({'b', 'c', 'd'}, functor.slice(source_table, 4, 2))
        end)

        it("should return empty list if start_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.same({}, functor.slice(source_table, 4))
        end)

        it("should return to end of list if end_index is greater than table size", function()
            local source_table = { 'a', 'b', 'c' }
            assert.same({'b', 'c'}, functor.slice(source_table, 2, 11))
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

    describe('fold', function()

        it('should be able to sum a list of integers', function()
            local list = { 1,2,3 }
            local sum = function(x, acc) return acc + x end
            assert.are_equal(6, functor.fold(sum, 0, list))
        end)

        it('should accept an init value', function()
            local list = { 1,2,3 }
            local sum = function(x, acc) return acc + x end
            assert.are_equal(10, functor.fold(sum, 4, list))
        end)

        it('should use first value as init if no init supplied', function()
            local list = {'a', 'b', 'c'}
            local keep_init = function(acc) return acc end
            assert.are_equal('a', functor.fold(keep_init, nil, list))
        end)

        it('should wrap non-table input as table', function()
            local function sum(x, acc) return acc + x end
            assert.are_equal(5, functor.fold(sum, 2, 3))
        end)

    end)

    describe('intersperse', function()

        it('should return an empty list for an empty list', function()
            assert.same({}, functor.intersperse('a', {}))
        end)

        it("should return the list unchanged if it's a singleton", function()
            assert.same({'a'}, functor.intersperse('b', {'a'}))
        end)

        it('should return a list with the specified item between each original list item', function()
            local item = '-'
            local list = {'a', 'b', 'c'}
            local result = functor.intersperse(item, list)
            assert.same({'a', '-', 'b', '-', 'c'}, result)
        end)
    end)

    describe('filter', function()

        it('should return empty list for empty list', function()
            local predicate = function(x) return x == 'b' end
            assert.same({}, functor.filter(predicate, {}))
        end)

        it('should return element for which condition is true', function()
            local predicate = function(x) return x == 'b' end
            assert.same({'b'}, functor.filter(predicate, {'a', 'b', 'c'}))
        end)


        it('should return all elements for which condition is true', function()
            local predicate = function(x) return x % 2 == 0 end
            assert.same({2,4}, functor.filter(predicate, {1,2,3,4,5}))
        end)

    end)

    describe('flatmap', function()

        it('should return empty list for empty list', function()
            local function func(x) return x*2 end
            assert.same({}, functor.flatmap(func, {}))
        end)

        it('should return singleton from singleton list', function()
            local function func(x) return x*2 end
            assert.same({6}, functor.flatmap(func, {3}))
        end)

        it('should return flat map from nested input', function()
            local function func(x) return {x*2} end
            assert.same({6,12}, functor.flatmap(func, {3,6}))
        end)

        it('should return curried function if no list provided', function()
            local function func(x) return {x*2} end
            local curried_function = functor.flatmap(func)
            assert.same({6,12}, curried_function({3,6}))
        end)

    end)

    describe('append()', function()

        it('should not modify original list', function()
            local orig = {7,8}
            functor.append(orig, 9)
            assert.same(orig, {7,8})
        end)

        it('should add element to end of list', function()
            assert.same({5,7,9}, functor.append({5,7}, 9))
        end)

    end)


    describe('concat()', function()

        it('should return empty list for two nil inputs', function()
            assert.same({}, functor.concat())
        end)

        it('should return empty list for two empty inputs', function()
            assert.same({}, functor.concat({},{}))
        end)

        it('should add two lists together', function()
            assert.same({36,42,69,107}, functor.concat({36,42},{69,107}))
        end)

        it('should not modify original lists', function()
            local first_list = {36,42}
            local second_list = {69,107}
            functor.concat(first_list, second_list)
            assert.same(first_list, {36,42})
            assert.same(second_list, {69,107})
        end)

    end)

    describe('clone()', function()

        it('should return empty list for empty list', function()
            assert.same({}, functor.clone({}))
        end)

        it('should return nil for nil', function()
            assert.same(nil, functor.clone())
        end)

        it('should return same list', function()
            assert.same({1,2,3,4}, functor.clone({1,2,3,4}))
        end)

        it('should return copy of original', function()
            local orig = {1,2,3,4}
            local copied = functor.clone(orig)
            orig[5] = 5
            assert.same({1,2,3,4}, copied)
        end)

        it('should return same object', function()
            local orig = {
                name = 'John',
                occupation = 'Welder'
            }
            assert.same(orig, functor.clone(orig))
        end)

    end)

end)
