local text = require('kraftwerk.util.text')

local function decode(json_string)
    if text.is_blank(json_string) then
        return ''
    end
    return vim.fn.json_decode(json_string)
end

return {
    decode = decode
}
