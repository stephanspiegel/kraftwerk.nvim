local io_handler = require('kraftwerk.io_handler')

describe('io_handler', function()

    describe('gather_input', function()

        it('should display error for missing required argument', function()
            local expected_args = {
                {
                    required = true,
                    name = 'requiredArgument'
                }
            }
            local result = io_handler.gather_input({args = expected_args}, nil, nil, nil)
            local message_produced = result.messages.err
            assert.are_equal('Missing required argument: requiredArgument', message_produced)
        end)

        it('should display error for value not included in "valid_values"', function()
            local expected_args = {
                {
                    name = 'constrainedArgument',
                    valid_values = { 'a', 'b', 'c' }
                }
            }
            local range_args = {}
            local result = io_handler.gather_input({args = expected_args}, nil, range_args, {'d'})
            local message_produced = result.messages.err
            assert.are_equal('"d" is not a valid value for constrainedArgument', message_produced)
        end)

        it('should return the default value if specified, and no value is supplied', function()
            local expected_args = {
                {
                    name = 'argumentWithDefault',
                    valid_values = { 'a', 'b', 'c' },
                    default_value = 'b'
                }
            }
            local result = io_handler.gather_input({args=expected_args}, nil, nil)
            assert.are_equal('b', result.argumentWithDefault)
        end)

        it('should return the value supplied', function()
            local expected_args = {
                {
                    name = 'fruit'
                }
            }
            local result = io_handler.gather_input({args=expected_args}, nil, nil, {'orange'})
            assert.are_equal('orange', result.fruit)
        end)

    end)

end)
