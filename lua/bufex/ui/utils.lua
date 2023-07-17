local api = vim.api
local ns = api.nvim_create_namespace('BufEx')
local U = {}


U.cmd_events = { 'BufEnter', 'BufLeave', 'WinClosed', 'WinEnter' }

---@param display_icon boolean
---@return table, table[]
function U.get_buffers(display_icon)
    local data = {}
    local hl = {}

    local bufs = api.nvim_list_bufs()
    bufs = vim.tbl_filter(function(buf)
            local is_loaded = api.nvim_buf_is_loaded(buf)
            local is_listed = vim.fn.buflisted(buf) == 1

            if not (is_loaded and is_listed) then
                return false
            end

            return true
        end, bufs)

    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
        local ext = string.match(name, "%w+%.(.+)") or name
        local icon, color = U.get_icon(name, ext, display_icon)

        if name ~= "" then
            table.insert(data, icon .. " " .. name)
            table.insert(hl, {#data-1, color})
        end
    end

    return data, hl
end

---@param name string
---@param ext string
---@param display boolean
---@return string, string
function U.get_icon(name, ext, display)
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')

    if not display then
        return ' ', ''
    end

    if not ok then
        return '', ''
    end

    local icon, color = dev_icons.get_icon(name, ext, { default = true })
    return icon, color
end

---@param buf number
---@param key string
---@param action string|function
---@param mode string? default 'n'
---@param opts table?
function U.keyset(buf, key, action, mode, opts)
    opts = opts or { nowait = true, silent = true }
    mode = mode or 'n'

    api.nvim_buf_set_keymap(buf, mode, key, action, opts)
end

-- file = 'index.js',
-- author = U.get_random_name(),
-- allow_save = true,
-- allow_edit = true,
-- password = '123'

local function get_buf_opts_info(data)
    local save = data.allow_save
    local edit = data.allow_edit

    local opts_save = save and 'save' or nil
    local opts_edit = edit and 'edit' or nil
    local opts_sep = save and edit and ', ' or ''

    if opts_sep == ', ' then
        return opts_save .. opts_sep .. opts_edit
    end

    return opts_save or opts_edit
end

function U.convert_buf_info(data)
    local main = {}
    local hl = {}

    for i, v in pairs(data) do
        local file = v.file
        local ext = file:match("%w+%.(.+)") or file
        local icon, color = U.get_icon(file, ext, true)

        table.insert(main, ' ' .. icon .. ' ' .. v.file)
        table.insert(hl, { #main - 1, color })

        local name = ' ' .. v.author
        local opts = '󱃕 ' .. get_buf_opts_info(v)
        local password = v.password and '󰒃 password' or nil

        for _, val in pairs({ name, opts, password }) do
            if val then
                table.insert(main, '    ' .. val)
            end
        end

        -- add extra space
        if i ~= #data then
            table.insert(main, '')
        end
    end

    return main, hl
end

---@param title string
---@param position 'left'|'right'
---@param lines table
---@param config Float
---@return number
---@return number
function U.setup_win_buf(title, position, lines, config)
    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)


    local height = vim.o.lines
    local width = vim.o.columns
    local pos = {
        width = math.ceil(width * 0.35),
        height = math.ceil(height * 0.7),
        row = math.ceil(height * 0.075),
        col = math.ceil(width * 0.15),
    }

    if position == 'right' then
        pos = {
            width = math.ceil(width * 0.35),
            height = math.ceil(height * 0.7),
            row = math.ceil(height * 0.075),
            col = math.ceil(width * 0.15 + width * 0.35 + 3),
        }
    end


    -- create window
    local win_opts = {
        relative = 'editor',
        width = pos.width,
        height = pos.height,
        row = pos.row,
        col = pos.col,
        title = string.format(' %s ', title),
        title_pos = 'center',
        style = "minimal",
        border = config.border,
    }

    local win = api.nvim_open_win(buf, false, win_opts)

    -- configure window
    api.nvim_win_set_option(win, "winblend", config.winblend)
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })

    -- add keymaps
    U.keyset(buf, config.keymap.select, ':echo "Select"<cr>')
    U.keyset(buf, config.keymap.quit, ':echo "Quit"<cr>')

    -- add hl
    for i = 0, #lines do
        api.nvim_buf_add_highlight(buf, ns, 'Normal', i, 0, -1)
    end
    api.nvim_set_option_value('winhighlight', 'FloatBorder:Normal', { win = win })

    return buf, win
end

return U
