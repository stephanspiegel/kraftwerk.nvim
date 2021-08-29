local function visual_selection_range(start_marker, end_marker)
    -- get position of start of visual area
    local _, csrow, cscol, _ = unpack(vim.fn.getpos(start_marker))
    -- end of visual area is the cursor position
    local _, cerow, cecol, _ = unpack(vim.fn.getpos(end_marker))
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
    local mode = vim.api.nvim_get_mode().mode
    local start_marker = "v"
    local end_marker = "."
    if mode ~= "v" and mode ~= "V" then
        start_marker = "'<"
        end_marker = "'>"
    end
    local start_row, start_column, end_row, end_column = visual_selection_range(start_marker, end_marker)
    if mode == "V" then
        start_column = 1
        end_column = 2^31 - 1
    end
    return get_selection_content(start_row, start_column, end_row, end_column)
end

local function get_current_line()
    local cursorline, cursorcolumn = unpack(vim.api.nvim_win_get_cursor(0))
end

return {
    get_visual_selection = get_visual_selection,
    get_current_line = get_current_line
}
