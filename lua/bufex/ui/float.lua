local api = vim.api
local U = require('bufex.utils')
local D = require('bufex.data')
local M = {}

---@class Window
---@field[1] number window_id
---@field[2] number buffer_id

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
        file = 'main.go,',
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

local function select_buffer()
    clear_buffers()

    local content, hl = U.get_all_buffers()
    local size = {
        width = 0.35,
        height = 0.7
    }
    local buf, win = U.setup_win_buf('Send buffer', 'left', size, content)

    -- autocmd for cursorline and win close
    api.nvim_create_autocmd(D.cmd_events, {
        buffer = buf,
        group = 'BufEx',
        callback = function(e)
            local ev = e.event

            if ev == 'WinClosed' then
                M.toggle_window({})
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
    for _, v in pairs(hl) do
        api.nvim_buf_add_highlight(buf, ns, v[2], v[1], 1, 3)
    end

    -- add keymaps
    U.keyset(buf, config.keymap.select, ':echo "Select"<cr>')

    -- select buffers by number
    for i = 0, 9 do
        U.keyset(buf, tostring(i), i .. 'gg')
    end
end

---@param data Buffers[]
local function receive_buffer(data)
    local content, hl = D.convert_buf_info(data)
    vim.print(vim.inspect(content))
    local size = {
        width = 0.35,
        height = 0.7
    }
    local buf, win = U.setup_win_buf('Receive buffers', 'right', size, content)

    -- autocmd for cursorline and win close
    api.nvim_create_autocmd(D.cmd_events, {
        buffer = buf,
        group = 'BufEx',
        callback = function(e)
            local ev = e.event

            if ev == 'WinClosed' then
                M.toggle_window({})
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

        select_buffer()

        -- FIXME!!
        receive_buffer({})
    end
end

---@param received_data Buffers[]
function M.toggle_window(received_data)
    is_visible = not is_visible

    clear_buffers()

    if is_visible then
        select_buffer()
        receive_buffer(received_data)

        -- keymap to switch windows
        local win_0, buf_0 = active_windows[1][1], active_windows[1][2]
        local win_1, buf_1 = active_windows[2][1], active_windows[2][2]
        local next_win = config.keymap.next_window

        U.keyset(buf_0, next_win, ':lua vim.api.nvim_set_current_win(' .. win_1 .. ')<cr>')
        U.keyset(buf_1, next_win, ':lua vim.api.nvim_set_current_win(' .. win_0 .. ')<cr>')
    end
end

---@param cfg Float
function M.setup(cfg)
    config = cfg

    api.nvim_create_autocmd('VimResized', {
        callback = function ()
            M.redraw()
        end
    })
end

return M
