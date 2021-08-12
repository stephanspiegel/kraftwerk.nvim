local function visual_selection_range()
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    if csrow < cerow or (csrow == cerow and cscol <= cecol) then
        return csrow, cscol, cerow, cecol
    else
        return cerow, cecol, csrow, cscol
    end
end

local function get_selection_content(start_row, start_column, end_row, end_column)
    local content = vim.api.nvim_buf_get_lines(0, start_row-1, end_row, false)
    if start_row == end_row then
        -- single-line selection
        content[1] = string.sub(content[1], start_column, end_column)
    else
        -- mult-line selection
        content[1] = string.sub(content[1], start_column)
        content[#content] = string.sub(content[#content], 1, end_column)
    end
    return table.concat(content, "\n")
end

local function get_visual_selection()
    local start_row, start_column, end_row, end_column = visual_selection_range()
    return get_selection_content(start_row, start_column, end_row, end_column)
end

local function contains(table, test_value)
    for _, value in ipairs(table) do
        if value == test_value then
            return true
        end
    end

    return false
end

local function open_result_buffer(buffer_name, buffer_content, file_type)
end

return {
    get_visual_selection = get_visual_selection,
    contains = contains
}
