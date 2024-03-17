local functor = require('kraftwerk.util.functor')

local number_to_english = {
    [0] = 'no',
    [1] = 'one',
    [2] = 'two',
    [3] = 'three',
    [4] = 'four',
    [5] = 'five',
    [6] = 'six',
    [7] = 'seven',
    [8] = 'eight',
    [9] = 'nine',
    [10] = 'ten',
    [11] = 'eleven',
    [12] = 'twelve'
}

local pluralize = function (format, number_of_things, noun)
    local number_string = tostring(number_of_things)
    if functor.has_key(number_to_english, number_of_things) then
        number_string = number_to_english[number_of_things]
    end
    local handled_noun = noun;
    if number_of_things ~= 1 then
        handled_noun = noun .. 's'
    end
    return format
        :gsub('{!number}', number_string)
        :gsub('{!noun}', handled_noun)
end

return {
    pluralize = pluralize
}
