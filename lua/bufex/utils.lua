local api = vim.api
local ns = api.nvim_create_namespace('BufEx')

local config = require('bufex.config')
local float = config.float

local D = require('bufex.data')
local U = {}


---@class HL
---@field[1] number line
---@field[2] string color

---@class Size
---@field width number
---@field height number


---@param tbl table
---@param key string|number
---@return table
function U.remove_key(tbl, key)
    local main = {}

    for k, v in pairs(tbl) do
        if k ~= key then
            main[k] = v
        end
    end

    return main
end

---@param range number
---@return table
function U.get_marks(range)
    local main = {}

    for i = 0, range do
        table.insert(main, i)
    end

    return main
end

function U.wrap(s, wrap)
    return wrap .. s .. wrap
end

---@param buf number
---@param key string
---@param action string|function
---@param mode string? default 'n'
---@param opts table?
function U.keyset(buf, key, action, mode, opts)
    opts = opts or { nowait = true, silent = true }
    opts['buffer'] = buf

    mode = mode or 'n'

    vim.keymap.set(mode, key, action, opts)
end

---@return string
function U.get_random_name()
    math.randomseed(os.time())
    return D.names[math.random(1, #D.names)]
end

---@return string icon
---@return string color
function U.get_icon(file)
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')
    local ext = file:match('%w+%.(.+)') or file

    -- icons disabled
    if not float.icons then
        return ' ', ''
    end

    -- can't find dev-icons
    if not ok then
        return '', ''
    end

    return dev_icons.get_icon(file, ext, { default = true })
end

---@param lines table<string>
---@return table<string>
function U.center_lines(lines)
    local width = math.floor(vim.o.columns * 0.4)
    local main = {}

    for _, v in pairs(lines) do
        local center = U.wrap(v, (' '):rep((width - #v) / 2))
        table.insert(main, center)
    end

    return main
end

---@return table buffers
---@return HL[] highlights
---@return table buffers_id
function U.get_all_buffers()
    local buffers = {}
    local buffers_id = {}
    local hl = {} ---@type HL[]

    -- filter existing buffers
    local bufs = api.nvim_list_bufs()
    bufs = vim.tbl_filter(function(buf)
            local is_loaded = api.nvim_buf_is_loaded(buf)
            local is_listed = vim.fn.buflisted(buf) == 1

            if not (is_loaded and is_listed) then
                return false
            end

            return true
        end, bufs)

    -- add icons
    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match('[^\\/]+$') or ''
        local icon, color = U.get_icon(name)

        if name ~= '' then
            table.insert(buffers, icon .. ' ' .. name)
            table.insert(buffers_id, buf)

            -- add to line
            table.insert(hl, { #buffers - 1, color })
        end
    end

    return buffers, hl, buffers_id
end

local active_windows = {} ---@type Window[]

---@param title string
---@param position 'left'|'right'|'center'
---@param size Size width-height in %
---@param lines table
---@return number buffer
---@return number window
function U.setup_win_buf(title, position, size, lines)
    local function clear_windows()
        vim.g.is_enabled_bufex = false

        for _, v in pairs(active_windows) do
            local win, buf = v[1], v[2]

            if win ~= nil and api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end

            if buf ~= nil and api.nvim_buf_is_valid(buf) then
                api.nvim_buf_delete(buf, { force = true })
            end
        end

        active_windows = {}
    end

    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local pos = D.get_win_position(position, size)

    -- create window
    local win_opts = {
        relative = 'editor',
        width = pos.width,
        height = pos.height,
        row = pos.row,
        col = pos.col,
        title = string.format(' %s ', title),
        title_pos = 'center',
        style = 'minimal',
        border = float.border,
    }

    local win = api.nvim_open_win(buf, false, win_opts)

    -- configure window
    api.nvim_win_set_option(win, 'winblend', float.winblend)
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })

    -- add highlights
    api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:Normal', { win = win })

    -- add keymap for quit
    U.keyset(buf, float.keymap.quit, function()
        clear_windows()
    end)

    -- if you select different window that float
    api.nvim_create_autocmd('WinEnter', {
        group = 'BufEx',
        callback = function()
            local selected = vim.tbl_filter(function(v)
                    local a_win = v[1]
                    local new_win = api.nvim_get_current_win()

                    return new_win == a_win
                end, active_windows)

            if #selected == 0 then
                clear_windows()
            end
        end
    })

    table.insert(active_windows, { win, buf })
    return buf, win
end

---@param cfg Configuration
function U.setup(cfg)
    config = cfg
    float = cfg.float
end

return U
