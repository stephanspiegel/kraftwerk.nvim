local text = require('kraftwerk.util.text')

describe('text', function()

    describe('starts_with', function()

        it("should return true if it starts with the specified prefix", function()
            assert(text.starts_with('yes, yes_or_no'))
        end)

        it("should return false if it starts with the specified prefix", function()
            assert.is_not_true(text.starts_with('no', 'yes or no'))
        end)

        it("should return curried function if no text specified", function()
            local starts_with_yes = text.starts_with('yes')
            assert(starts_with_yes('yes or no'))
        end)

    end)

    describe('trim', function()

        it('should remove leading and trailing whitespace', function()
            assert.are_equal('orange', text.trim('  \torange\n  '))
        end)

        it('should not remove inner whitespace', function()
            local expected = 'this is a sentence'
            local input = 'this is a sentence'
            assert.are_equal(expected, text.trim(input))
        end)

    end)

    describe('is_blank', function()

        it('should return true if input is nil', function()
            assert.is_true(text.is_blank())
        end)

        it('should return true if input is empty string', function()
            assert.is_true(text.is_blank(''))
        end)

        it('should return true if input is all whitespace', function()
            assert.is_true(text.is_blank('  \t\n  '))
        end)

        it('should return false if any part of input is not whitespace', function()
            assert.is_false(text.is_blank('  \tnotblank\n'))
        end)

    end)

    describe('split', function()

        it('should return list of words', function()
            local input = 'A small step for a man'
            local expected = { 'A', 'small', 'step', 'for', 'a', 'man'}
            assert.same(expected, text.split(input))
        end)

        it('should split on comma', function()
            local input = 'bainberry,chokenut,moonrock,kippers'
            local expected = {'bainberry', 'chokenut', 'moonrock', 'kippers'}
            assert.same(expected, text.split(input, ','))
        end)
    end)

end)
