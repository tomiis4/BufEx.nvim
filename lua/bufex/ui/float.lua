local api = vim.api
local U = require('bufex.utils')
local D = require('bufex.data')
local M = {}


---@class Window
---@field[1] number window_id
---@field[2] number buffer_id

local shared_buffers = {} ---@type Buffers[]
local active_windows = {} ---@type Window[]
local buffers_id = {}

local config = require('bufex.config').float ---@type Float
local config_lt = require('bufex.config').local_transfer ---@type LocalTransfer

local is_visible = false
local selected_buf = nil

api.nvim_create_augroup('BufEx', {})

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

function M.change_password(buf)
    local password = api.nvim_buf_get_lines(tonumber(buf), 0, 1, false)[1]

    config_lt.password = password
    M.toggle_item_buf(true)
end

local function enter_password()
    clear_buffers()

    local size = { width = 0.4, height = 1 / vim.o.lines }
    local buf, win = U.setup_win_buf('Enter password', 'center', size, {})


    table.insert(active_windows, { win, buf })

    api.nvim_set_option_value('modifiable', true, { buf = buf })

    vim.cmd('startinsert')
    api.nvim_buf_set_keymap(buf, 'i', '<cr>', '<esc><cr>', {})
    api.nvim_buf_set_keymap(buf, 'n', '<cr>',
        ':lua require("bufex.ui.float").change_password(' .. buf ..') <cr>', {})

    api.nvim_set_current_win(win)
end

---@param send boolean?
function M.toggle_item_buf(send)
    local row = api.nvim_win_get_cursor(0)[1]
    local col = api.nvim_win_get_cursor(0)[2]
    local password = config_lt.opts.need_password

    if row == 5 or send then
        if send or password == 'never' then
            require('bufex.local.local').send_buffer(selected_buf, config_lt)

            -- toggle it :D
            require('bufex').toggle()
            require('bufex').toggle()
        elseif password ~= nil then
            enter_password()
        end
    elseif row == 1 then
        config_lt.opts.allow_save = not config_lt.opts.allow_save
    elseif row == 2 then
        config_lt.opts.allow_edit = not config_lt.opts.allow_edit
    elseif row == 3 then
        if password == 'never' then
            config_lt.opts.need_password = 'ask'
        elseif password == 'ask' then
            config_lt.opts.need_password = 'always'
        elseif password == 'always' then
            config_lt.opts.need_password = 'never'
        end
    end

    if row ~= 5 and not send then
        M.select_buf_item()
        api.nvim_win_set_cursor(0, { row, col })
    end
end

-- TODO add config, like opts, password
function M.select_buf_item()
    local line = api.nvim_win_get_cursor(0)[1]
    selected_buf = selected_buf == nil and buffers_id[line] or selected_buf

    clear_buffers()

    -- TOOD center those
    local lines = {
        'Allow save: ' .. tostring(config_lt.opts.allow_save),
        'Allow edit: ' .. tostring(config_lt.opts.allow_edit),
        'Need password: ' .. config_lt.opts.need_password,
        '',
        'CONTIUNE'
    }
    local size = { width = 0.4, height = 0.5, }
    local buf, win = U.setup_win_buf('Select options', 'center', size, lines)

    table.insert(active_windows, { win, buf })

    api.nvim_set_option_value('cursorline', true, { buf = buf })
    api.nvim_set_current_win(win)

    U.keyset(buf, '<cr>', ':lua require("bufex.ui.float").toggle_item_buf(false) <cr>')
end

local function select_buffer()
    clear_buffers()

    local content, hl, ids = U.get_all_buffers()
    buffers_id = ids
    local size = { width = 0.35, height = 0.7 }
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

    -- send buffer
    U.keyset(buf, config.keymap.select, ":lua require('bufex.ui.float').select_buf_item() <cr>")

    -- select buffers by number
    for i = 0, 9 do
        U.keyset(buf, tostring(i), i .. 'gg')
    end
end

local function receive_buffer()
    local content, hl = D.convert_buf_info(shared_buffers)
    local size = { width = 0.35, height = 0.7 }
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

        receive_buffer()
    end
end

---@param received_data Buffers[]
function M.toggle_window(received_data)
    is_visible = not is_visible

    clear_buffers()

    if is_visible then
        shared_buffers = received_data

        select_buffer()
        receive_buffer()

        -- keymap to switch windows
        local win_0, buf_0 = active_windows[1][1], active_windows[1][2]
        local win_1, buf_1 = active_windows[2][1], active_windows[2][2]
        local next_win = config.keymap.next_window

        U.keyset(buf_0, next_win, ':lua vim.api.nvim_set_current_win(' .. win_1 .. ')<cr>')
        U.keyset(buf_1, next_win, ':lua vim.api.nvim_set_current_win(' .. win_0 .. ')<cr>')
    end
end

---@param cfg Float
---@param cfg_lt LocalTransfer
function M.setup(cfg, cfg_lt)
    config = cfg
    config_lt = cfg_lt

    api.nvim_create_autocmd('VimResized', {
        callback = function()
            M.redraw()
        end
    })
end

return M
