---@class Window
---@field[1] number window_id
---@field[2] number buffer_id


local input = require('bufex.ui.input')
local select = require('bufex.ui.select')

local floor = math.floor
local U = require('bufex.utils')
local D = require('bufex.data')
local M = {}

local active_windows = {} ---@type Window[]
local shared_buffers = {} ---@type Buffers[]
local available_buffers = {} ---@type table<number> buffers in showed order

local config = require('bufex.config').float ---@type Float
local config_lt = require('bufex.config').local_transfer ---@type LocalTransfer

local api = vim.api
local is_menu_visible = false
local selected_buf = nil

local ns = api.nvim_create_namespace('BufEx')
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

---@param row number
---@param instant_send boolean?
local function toggle_buf_option(row, instant_send)
    local _, col = unpack(api.nvim_win_get_cursor(0))
    local password = config_lt.opts.need_password

    clear_buffers()
    is_menu_visible = false

    if row == 5 or instant_send then
        if instant_send or password == 'never' then
            if password == 'never' then
                config_lt.password = 'nil'
            end

            require('bufex.local.local').send_buffer(selected_buf, config_lt)
            require('bufex').toggle()
        elseif password then
            -- ask for password

            clear_buffers()
            input.new_input('Enter password', function(res)
                config_lt.password = res == '' and nil or res
                toggle_buf_option( -1, true)
            end)
        end
    else
        -- toggle function

        if row == 1 then
            config_lt.opts.allow_save = not config_lt.opts.allow_save
        elseif row == 2 then
            config_lt.opts.allow_edit = not config_lt.opts.allow_edit
        elseif row == 3 then
            if password == 'never' then
                config_lt.opts.need_password = 'always'
            elseif password == 'always' then
                config_lt.opts.need_password = 'never'
            end
        end

        M.select_buf_item()
        api.nvim_win_set_cursor(0, { row + 1, col })
    end
end

--- nwm how it works -v
--- TODO: only second time it show all send buffers
---@param row number?
function M.select_buf_item(row)
    clear_buffers()

    local keys = config.keymap.opts
    local line = row or 0
    selected_buf = selected_buf or available_buffers[line]

    local lines = {
        '',
        '(' .. keys.toggle_save .. ') allow save: ' .. tostring(config_lt.opts.allow_save),
        '(' .. keys.toggle_edit .. ') allow edit: ' .. tostring(config_lt.opts.allow_edit),
        '(' .. keys.toggle_password .. ') password: ' .. config_lt.opts.need_password .. ' ',
        '', 'continue('.. keys.continue ..')'
    }
    local width = floor(vim.o.columns * 0.4)
    local size = { width = 0.4, height = 0.3, }
    local marks = U.get_marks(#lines)

    local buf, win = select.new_select('Select options', 'center', size,
            { lines, marks, true },
            function(_, n_option)
                toggle_buf_option(n_option - 1, false)
            end
        )

    table.insert(active_windows, { win, buf })
    api.nvim_set_option_value('cursorline', true, { buf = buf })
    api.nvim_win_set_cursor(win, { 2, 0 })

    -- highlight continue option
    local hl_start = floor(width / 2 - #lines[6] / 2) - 1
    local hl_end = floor(hl_start + #lines[6]) + 2

    api.nvim_buf_add_highlight(buf, ns, 'CursorLine', 5, hl_start, hl_end)
    api.nvim_buf_add_highlight(buf, ns, 'Comment', 5, hl_start + 9, hl_end)

    -- select by keymap
    U.keyset(buf, keys.toggle_save, function() toggle_buf_option(1, false) end)
    U.keyset(buf, keys.toggle_edit, function() toggle_buf_option(2, false) end)
    U.keyset(buf, keys.toggle_password, function() toggle_buf_option(3, false) end)
    U.keyset(buf, keys.continue, function() toggle_buf_option(5, false) end)
end

local function select_buffer()
    clear_buffers()

    local size = { width = 0.35, height = 0.7 }
    local lines, hl, ids = U.get_all_buffers()

    available_buffers = ids
    selected_buf = nil

    local marks = U.get_marks(#lines)
    local buf, win = select.new_select('Send buffer', 'left', size,
            { lines, marks },
            function(_, n_option)
                M.select_buf_item(n_option)
                is_menu_visible = false
            end
        )

    table.insert(active_windows, { win, buf })
    api.nvim_set_option_value('number', true, { buf = buf })

    -- highlight icons
    for _, v in pairs(hl) do
        api.nvim_buf_add_highlight(buf, ns, v[2], v[1], 1, 3)
    end

    -- select buffers by number
    for i = 1, 9 do
        U.keyset(buf, tostring(i), '<cmd> ' .. i .. ' <cr>')
    end
end

local function receive_buffer()
    local lines, options_start, hl = D.convert_buf_info(shared_buffers)

    local size = { width = 0.35, height = 0.7 }
    local buf, win = select.new_select('Receive buffers', 'right', size,
            { lines, options_start },
            function(_, n_option)
                -- TODO: make new separated function for this
                -- TODO: implement - password, save
                is_menu_visible = false
                clear_buffers()

                local got_buf = shared_buffers[n_option]
                local buf = api.nvim_create_buf(true, false)

                api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(got_buf.content, '\n'))
                api.nvim_buf_set_name(buf, got_buf.buffer_name)
                api.nvim_set_option_value('modifiable', got_buf.allow_edit, { buf = buf })

                print(got_buf.buffer_name)
                api.nvim_win_set_buf(0, buf)
            end
        )

    table.insert(active_windows, { win, buf })
    api.nvim_set_option_value('cursorline', true, { buf = buf })

    -- highlight buffer name
    for _, v in pairs(hl) do
        api.nvim_buf_add_highlight(buf, ns, v[2], v[1], 0, -1)
    end
end

function M.redraw()
    if is_menu_visible then
        clear_buffers()

        select_buffer()

        receive_buffer()
    end
end

---@param received_data Buffers[]?
function M.toggle_window(received_data)
    received_data = received_data or {}
    is_menu_visible = not is_menu_visible

    clear_buffers()

    if is_menu_visible then
        shared_buffers = #received_data == 0 and shared_buffers or received_data

        select_buffer()
        receive_buffer()

        -- keymap to switch windows
        local win_0, buf_0 = active_windows[1][1], active_windows[1][2]
        local win_1, buf_1 = active_windows[2][1], active_windows[2][2]
        local next_win = config.keymap.next_window

        U.keyset(buf_0, next_win, function()
            api.nvim_set_current_win(win_1)
        end)

        U.keyset(buf_1, next_win, function()
            api.nvim_set_current_win(win_0)
        end)
    end
end

---@param cfg Float
---@param cfg_lt LocalTransfer
function M.setup(cfg, cfg_lt)
    config = cfg
    config_lt = cfg_lt

    -- redraw main menu
    api.nvim_create_autocmd('VimResized', {
        callback = function()
            M.redraw()
        end
    })
end

return M
