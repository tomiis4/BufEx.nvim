local api = vim.api
local U = require('bufex.utils')
local M = {}

-- remove
local local_method = require('bufex.local.local')

---@class Window
---@field[1] number window_id
---@field[2] number buffer_id

---@type Window[]
local active_windows = {}

--[[


|------------------| |------------------|
| Send buffer      | | Receive buffer   |
|------------------| |------------------|
| 1) index.js      | | 1) index.js      |
| 2) README.md     | |    - tomiis4     |
| 3) style.css     | |    - edit, save  |
|                  | |    - password    |
|                  | |                  |
|------------------| |------------------|


|---------------------------------------|
| Send buffer                           |
|---------------------------------------|
| - index.js                            |
|   - edit = TRUE                       |
|   - save = FALSE                      |
|   - password = FALSE                  |
|                                       |
|---------------------------------------|


|-Enter password------------------------|
|                                       |
|---------------------------------------|


]]

local function delete_buffers()
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

---@param config Float
---@param content table
function M.select_buffer(config, content)
    delete_buffers()

    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, content)


    local height = vim.o.lines
    local width = vim.o.columns
    local pos = {
        width = math.ceil(width * 0.35),
        height = math.ceil(height * 0.7),
        row = math.ceil(height * 0.075),
        col = math.ceil(width * 0.15),
    }


    -- create window
    local win_opts = {
        relative = 'editor',

        width = pos.width,
        height = pos.height,
        row = pos.row,
        col = pos.col,

        title = ' Send buffer ',
        title_pos = 'center',

        style = "minimal",
        border = config.border,
    }


    local win = api.nvim_open_win(buf, true, win_opts)
    table.insert(active_windows, {win, buf})


    -- configure window
    api.nvim_win_set_option(win, "winblend", config.winblend)
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })
    api.nvim_set_option_value('cursorline', true, { buf = buf })


    -- add keymaps
    U.keyset(buf, config.keymap.select, ':echo "Select"<cr>')
    U.keyset(buf, config.keymap.quit, ':echo "Quit"<cr>')
end

---@param config Float
---@param content table
function M.receive_buffer(config, content)
    -- delete_buffers()

    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, content)


    local height = vim.o.lines
    local width = vim.o.columns
    local pos = {
        width = math.ceil(width * 0.35),
        height = math.ceil(height * 0.7),
        row = math.ceil(height * 0.775),
        col = math.ceil(width * 0.5),
    }


    -- create window
    local win_opts = {
        relative = 'editor',

        width = pos.width,
        height = pos.height,
        row = pos.row,
        col = pos.col,

        title = ' Receive buffers ',
        title_pos = 'center',

        style = "minimal",
        border = config.border,
    }


    local win = api.nvim_open_win(buf, true, win_opts)
    table.insert(active_windows, {win, buf})


    -- configure window
    api.nvim_win_set_option(win, "winblend", config.winblend)
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })
    api.nvim_set_option_value('cursorline', true, { buf = buf })


    -- add keymaps
    U.keyset(buf, config.keymap.select, ':echo "Select"<cr>')
    U.keyset(buf, config.keymap.quit, ':echo "Quit"<cr>')
end

---@param config Float
function M.toggle_window(config, content)
    
end

return M
