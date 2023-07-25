---@class SelectScreen
---@field [1] number win
---@field [2] number buf


local select_screens = {} ---@type SelectScreen[]
local api = vim.api

local D = require('bufex.data')
local U = require('bufex.utils')
local M = {}


local function clear_screens()
    for _, v in pairs(select_screens) do
        local win, buf = v[1], v[2]

        if win ~= nil and api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end

        if buf ~= nil and api.nvim_buf_is_valid(buf) then
            api.nvim_buf_delete(buf, { force = true })
        end
    end

    select_screens = {}
end

---@param title string
---@param position 'left'|'right'|'center'
---@param size Size
---@param content table<table<string>, table<number>, boolean> -- 1) val, 2) val start, 3) center
---@param callback fun(option: string, n_option: number)
---@return number, number
function M.new_select(title, position, size, content, callback)
    content[1] = content[3] and U.center_lines(content[1]) or content[1]
    local buf, win = U.setup_win_buf(title, position, size, content[1])

    -- configure win and register it to `input_screens`
    api.nvim_set_current_win(win)
    table.insert(select_screens, { win, buf })

    -- get and return selected item
    local function select_item()
        local row = api.nvim_win_get_cursor(0)[1]

        local i = 1
        while i <= #content[2] do
            local ct_min = content[2][i]
            local ct_max = content[2][i + 1] or row

            if row >= ct_min and row <= ct_max then
                break
            end

            i = i + 1
        end

        callback(content[1][i], i)
    end

    -- autocmd for cursorline and win close
    api.nvim_create_autocmd(D.cmd_events, {
        buffer = buf,
        group = 'BufEx',
        callback = function(e)
            local ev = e.event

            if ev == 'WinClosed' then
                clear_screens()
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

    -- autocmd for resizing
    api.nvim_create_autocmd('VimResized', {
        buffer = buf,
        group = 'BufEx',
        callback = function()
            clear_screens()
            M.new_select(title, position, size, content, callback)
        end
    })

    vim.keymap.set('n', '<cr>', select_item, { buffer = buf, })
    return buf, win
end

return M
