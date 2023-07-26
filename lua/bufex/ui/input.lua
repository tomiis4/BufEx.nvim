---@class InputScreen
---@field [1] number win
---@field [2] number buf


local input_screens = {} ---@type InputScreen[]
local api = vim.api

local U = require('bufex.utils')
local M = {}


local function clean_screens()
    for _, v in pairs(input_screens) do
        local win, buf = v[1], v[2]

        if win ~= nil and api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end

        if buf ~= nil and api.nvim_buf_is_valid(buf) then
            api.nvim_buf_delete(buf, { force = true })
        end
    end

    input_screens = {}
end

---@param title string
---@param callback fun(res: string)
---@param value string? only for resizing
function M.new_input(title, callback, value)
    value = value or ''
    local size = { width = 0.4, height = 1 / vim.o.lines }
    local buf, win = U.setup_win_buf(title, 'center', size, { value })

    -- configure win and register it to `input_screens`
    api.nvim_set_option_value('modifiable', true, { buf = buf })
    api.nvim_set_current_win(win)
    table.insert(input_screens, { win, buf })

    -- insert & confirm
    vim.cmd('startinsert')

    -- listening for I/O
    U.keyset(buf, '<cr>', '<esc>', 'i')
    api.nvim_create_autocmd({ 'InsertChange', 'CursorMovedI', 'ModeChanged' }, {
        buffer = buf,
        callback = function(e)
            value = api.nvim_buf_get_lines(0, 0, 1, false)[1]

            if e.event == 'ModeChanged' and vim.fn.mode() ~= 'i' then
                vim.cmd('stopinsert')
                clean_screens()
                callback(value)
            end
        end
    })

    -- autocmd for resizing
    api.nvim_create_autocmd('VimResized', {
        buffer = buf,
        group = 'BufEx',
        callback = function()
            clean_screens()
            M.new_input(title, callback, value)
        end
    })
end

return M
