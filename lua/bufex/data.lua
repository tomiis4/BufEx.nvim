local D = {}

D.names = { 'Lion', 'Elephant', 'Tiger', 'Giraffe', 'Monkey', 'Dolphin', 'Penguin', 'Koala', 'Cheetah', 'Gorilla' }

D.messages = {
    ['OK'] = {
        ['CONNECT'] = 'Connection was established successfully',
        ['CREATE'] = 'Server was created successfully',
        ['CLOSE'] = 'Server was closed successfully',
        ['SEND'] = 'Data was sent successfully',
        ['RECEIVE'] = 'Data was received successfully',
    },
    ['ERROR'] = {
        ['CONNECT'] = 'Failed to establish connection',
        ['CREATE'] = 'Failed to create server',
        ['CLOSE'] = 'Failed to close server',
        ['SEND'] = 'Failed to send data',
        ['RECEIVE'] = 'Failed to receive data',
    }
}

D.cmd_events = { 'BufEnter', 'BufLeave', 'WinClosed', 'WinEnter' }

---@param position 'left'|'right'|'center'
---@param size Size width-height in %
function D.get_win_position(position, size)
    local height = vim.o.lines
    local width = vim.o.columns
    local floor = math.floor

    if position == 'left' then
        return {
            width = floor(width * size.width),
            height = floor(height * size.height),
            row = floor(height * ((1 - size.height) / 4)),
            col = floor(width / 2 - size.width * width)
        }
    end

    if position == 'right' then
        return {
            width = floor(width * size.width),
            height = floor(height * size.height),
            row = floor(height * ((1 - size.height) / 4)),
            col = floor(width / 2 - size.width * width + width * size.width + 3)
        }
    end

    -- center is default
    return {
        width = floor(width * size.width),
        height = floor(height * size.height),
        row = floor((height - (height * 0.5)) / 2) - 1,
        col = floor(width / 2 - size.width * width / 2)
    }
end

--- convert shadred buffers to one array
---@param data Buffers[]
---@return table options
---@return table options_start
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
    ---@return string icon
    ---@return string color
    local function get_icon(file)
        local ok, dev_icons = pcall(require, 'nvim-web-devicons')
        local ext = file:match('%w+%.(.+)') or file

        -- can't find dev-icons
        if not ok then
            return '', ''
        end

        return dev_icons.get_icon(file, ext, { default = true })
    end

    local lines = {}
    local options_start = {}
    local hl = {}

    for k, v in pairs(data) do
        local file = v.buffer_name
        local icon, color = get_icon(file)

        table.insert(lines, ' ' .. icon .. ' ' .. file)
        table.insert(options_start, #lines)
        table.insert(hl, { #lines - 1, color })

        local name = ' ' .. v.client_name
        local opts = get_buf_opts_info(v) and ('󱃕 ' .. get_buf_opts_info(v)) or nil
        local password = v.password ~= 'nil' and '󰒃 password' or nil

        for _, val in pairs({ name, opts, password }) do
            if val then
                table.insert(lines, '    ' .. val)
            end
        end

        -- add extra space at the end
        if k ~= #data then
            table.insert(lines, '')
        end
    end

    return lines, options_start, hl
end

return D
