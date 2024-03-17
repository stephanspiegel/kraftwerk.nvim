local english = require("kraftwerk.util.english")

describe('english', function ()

    describe('pluralize', function()
        it('keeps a singluar sentence singular', function ()
            assert.are.equal('found one complete brizbar', english.pluralize('found {!number} complete {!noun}', 1, 'brizbar'))
        end)
        it('makes a sentence plural if the number is not 1', function ()
            assert.are.equal('found seven complete brizbars', english.pluralize('found {!number} complete {!noun}', 7, 'brizbar'))
        end)
        it('handles zero numbers of things', function ()
            assert.are.equal('found no complete brizbars', english.pluralize('found {!number} complete {!noun}', 0, 'brizbar'))
        end)
    end
    )

end)

