local api = vim.api
local U = require('bufex.utils')
local FloatU = require('bufex.ui.utils')
local M = {}

---@class Window
---@field[1] number window_id
---@field[2] number buffer_id

---@class Buffer
---@field file string
---@field author string
---@field allow_save boolean
---@field allow_edit boolean
---@field password string|nil

local active_windows = {} ---@type Window[]
local config = require('bufex.config').float ---@type Float
local is_visible = false

api.nvim_create_augroup('BufEx', {})

local get_data = {
    {
        file = 'index.js',
        author = U.get_random_name(),
        allow_save = true,
        allow_edit = true,
        password = '123'
    },
    {
        file = 'README.md',
        author = U.get_random_name(),
        allow_save = true,
        allow_edit = false,
        password = '1234'
    },
    {
        file = 'main.go',
        author = U.get_random_name(),
        allow_save = false,
        allow_edit = true,
        password = nil
    }
}


local function clear_buffers()
    -- clean autocmds
    api.nvim_clear_autocmds({
        group = 'BufEx'
    })

    -- clean windows/buffers
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

---@param content table
---@param hl table
function M.select_buffer(content, hl)
    clear_buffers()
    local buf, win = FloatU.setup_win_buf('Send buffer', 'left', content, config)

    -- autocmd for cursorline
    api.nvim_create_autocmd(FloatU.cmd_events, {
        buffer = buf,
        group = 'BufEx',
        callback = function(e)
            local ev = e.event

            if ev == 'WinClosed' then
                M.toggle_window()
            else
                local set_line = ev == 'BufEnter' or ev == 'WinEnter'

                api.nvim_set_option_value(
                    'cursorline',
                    set_line,
                    { buf = buf }
                )
            end
        end
    })

    table.insert(active_windows, { win, buf })
    api.nvim_set_option_value('number', true, { buf = buf })

    -- add hl
    local ns = api.nvim_create_namespace('BufEx')
    print(vim.inspect(hl))
    for _, v in pairs(hl) do
        api.nvim_buf_add_highlight(buf, ns, v[2], v[1], 1, 3)
    end

    -- select buffers by number
    for i = 0, 9 do
        FloatU.keyset(buf, tostring(i), i .. 'gg')
    end
end

---@param data Buffer[]
function M.receive_buffer(data)
    local content, hl = FloatU.convert_buf_info(data)
    local buf, win = FloatU.setup_win_buf('Receive buffers', 'right', content, config)

    -- autocmd for cursorline
    api.nvim_create_autocmd(FloatU.cmd_events, {
        buffer = buf,
        group = 'BufEx',
        callback = function(e)
            local ev = e.event

            if ev == 'WinClosed' then
                M.toggle_window()
            else
                local set_line = ev == 'BufEnter' or ev == 'WinEnter'

                api.nvim_set_option_value(
                    'cursorline',
                    set_line,
                    { buf = buf }
                )
            end
        end
    })

    table.insert(active_windows, { win, buf })

    local ns = api.nvim_create_namespace('BufEx')
    for _, v in pairs(hl) do
        api.nvim_buf_add_highlight(buf, ns, v[2], v[1], 0, -1)
    end

    api.nvim_set_current_win(win)
end

function M.redraw()
    if is_visible then
        clear_buffers()

        M.select_buffer({ 'index.lua', 'README.md' })

        M.receive_buffer({ 'buffer' })
    end
end

function M.toggle_window()
    is_visible = not is_visible

    clear_buffers()

    if is_visible then
        local buffers, hl = FloatU.get_buffers(config.icons)
        M.select_buffer(buffers, hl)
        M.receive_buffer(get_data)

        -- keymap to switch windows
        local win_0, buf_0 = active_windows[1][1], active_windows[1][2]
        local win_1, buf_1 = active_windows[2][1], active_windows[2][2]
        local next_win = config.keymap.next_window

        FloatU.keyset(buf_0, next_win, ':lua vim.api.nvim_set_current_win(' .. win_1 .. ')<cr>')
        FloatU.keyset(buf_1, next_win, ':lua vim.api.nvim_set_current_win(' .. win_0 .. ')<cr>')
    end
end

---@param cfg Float
function M.setup(cfg)
    config = cfg
end

return M
