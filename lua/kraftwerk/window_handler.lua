local api = vim.api

local buffer_handle_by_name = {}

local function open_result_buffer(buffer_name, buffer_content, file_type)
    --[[ 
    let l:lines = util#split_on_newlines(a:buffercontent)
    let l:result_buffer = bufnr(a:buffername, 1)
    execute l:result_buffer . 'buffer'
    setlocal bufhidden=hide buftype=nofile noswapfile modifiable noreadonly
    execute 'setlocal filetype=' . l:filetype
    call append(0, l:lines)
    call deletebufline('%', len(l:lines) + 1, '$')
    setlocal readonly nomodifiable 
    ]]
    local result_buffer_handle = buffer_handle_by_name[buffer_name]
    if result_buffer_handle == nil then
        result_buffer_handle = api.nvim_create_buf(1, 1)
        print("new buffer: " .. result_buffer_handle)
        buffer_handle_by_name[buffer_name] = result_buffer_handle
        api.nvim_buf_set_name(result_buffer_handle, buffer_name)
    end
    api.nvim_buf_set_lines(result_buffer_handle, 0, -1, 0, buffer_content)
    print("buffer: "..result_buffer_handle)
    api.nvim_set_current_buf(result_buffer_handle)
end

return {
    open_result_buffer = open_result_buffer
}
