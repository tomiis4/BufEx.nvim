local config = require('bufex.config')

local is_server_on = false
local is_enabled = false

local D = require('bufex.data')
local U = require('bufex.utils')
local UI = require('bufex.ui.float')
local M = {}

local LT = require('bufex.local.local')
local LT_server = config.local_transfer.opts.server

-- TODO: fix keymaps to be user entered
-- TODO: fix exit window on click on another win
-- TODO: real-time connection?
-- TODO: add syntax and language support

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- setup data
    U.setup(config)
    LT.setup(config.local_transfer)
    UI.setup(config.float, config.local_transfer)
end

function M.toggle()
    is_enabled = not is_enabled

    if not is_server_on then
        LT.listen(LT_server.host, LT_server.port)
        is_server_on = true
    end

    -- close server
    if not is_enabled then
        UI.toggle_window({})
        return
    end

    -- get data from server
    LT.get_buffers(vim.schedule_wrap(function(res, err)
        if err then
            vim.notify(D.messages['ERROR']['RECEIVE'] .. ': ' .. err)

            is_server_on = false
            is_enabled = false

            return
        end

        vim.print(vim.inspect(res))
        UI.toggle_window(res)
    end))
end

return M
