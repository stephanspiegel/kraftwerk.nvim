local api = vim.api

local buffer_handle_by_name = {}

local function open_result_buffer(buffer_data)
    dump(buffer_data)
    local buffer_name = buffer_data.title
    local buffer_content = buffer_data.content
    local file_type = buffer_data.file_type
    local result_buffer_handle = buffer_handle_by_name[buffer_name]
    if result_buffer_handle == nil then
        result_buffer_handle = api.nvim_create_buf(1, 1)
        buffer_handle_by_name[buffer_name] = result_buffer_handle
        api.nvim_buf_set_name(result_buffer_handle, buffer_name)
    end
    api.nvim_buf_set_lines(result_buffer_handle, 0, -1, 0, buffer_content)
    api.nvim_set_current_buf(result_buffer_handle)
    vim.bo.filetype = file_type
end

return {
    open_result_buffer = open_result_buffer
}
