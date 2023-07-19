-- local U = require('bufex.utils')
local D = {}

D.names = { 'Lion', 'Elephant', 'Tiger', 'Giraffe', 'Monkey', 'Dolphin', 'Penguin', 'Koala', 'Cheetah', 'Gorilla' }

D.messages = {
    ['OK'] = {
        ['CONNECT'] = 'Connection was established successfully.',
        ['CREATE'] = 'Server was created successfully.',
        ['CLOSE'] = 'Server was closed successfully.',
        ['SEND'] = 'Data was sent successfully.',
        ['RECEIVE'] = 'Data was received successfully.',
    },
    ['ERROR'] = {
        ['CONNECT'] = 'Failed to establish connection.',
        ['CREATE'] = 'Failed to create server.',
        ['CLOSE'] = 'Failed to close server.',
        ['SEND'] = 'Failed to send data.',
        ['RECEIVE'] = 'Failed to receive data.',
    }
}

D.cmd_events = { 'BufEnter', 'BufLeave', 'WinClosed', 'WinEnter' }

---@param position 'left'|'right'|'center'
---@param size Size width-height in %
function D.get_win_size(position, size)
    local height = vim.o.lines
    local width = vim.o.columns
    local ceil = math.ceil

    if position == 'left' then
        return {
            width = ceil(width * size.width),
            height = ceil(height * size.height),
            row = ceil(height * ((1 - size.height) / 4)),
            col = ceil(width / 2 - size.width * width)
        }
    end

    if position == 'right' then
        return {
            width = ceil(width * size.width),
            height = ceil(height * size.height),
            row = ceil(height * ((1 - size.height) / 4)),
            col = ceil(width / 2 - size.width * width + width * size.width + 3)
        }
    end

    -- center is default
    return {
        width = ceil(width * size.width),
        height = ceil(height * size.height),
        row = ceil(height * ((1 - size.height) / 4)),
        col = ceil(width / 2 - size.width * width / 2)
    }
end

--- convert shadred buffers to one array
---@param data Buffers[]
---@return table main
---@return table hl
function D.convert_buf_info(data)
    ---@param data_buf Buffers
    ---@return string|nil
    local function get_buf_opts_info(data_buf)
        local save = data_buf.allow_save
        local edit = data_buf.allow_edit

        local opts_save = save and 'save' or nil
        local opts_edit = edit and 'edit' or nil
        local opts_sep = save and edit and ', ' or ''

        if opts_sep == ', ' then
            return opts_save .. opts_sep .. opts_edit
        end

        return opts_save or opts_edit
    end

    local main = {}
    local hl = {}

    for k, v in pairs(data) do
        local file = v.buffer_name
        local icon, color = '', ''

        table.insert(main, ' ' .. icon .. ' ' .. v.buffer_name)
        table.insert(hl, { #main - 1, color })

        local name = ' ' .. v.client_name
        local opts = '󱃕 ' .. get_buf_opts_info(v)
        local password = v.password and '󰒃 password' or nil

        for _, val in pairs({ name, opts, password }) do
            if val then
                table.insert(main, '    ' .. val)
            end
        end

        -- add extra space at the end
        if k ~= #data then
            table.insert(main, '')
        end
    end

    return main, hl
end

return D
