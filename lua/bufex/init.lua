local config = require('bufex.config')

local is_server_on = false

local D = require('bufex.data')
local U = require('bufex.utils')
local UI = require('bufex.ui.float')
local M = {}

local LT = require('bufex.local.local')
local T_server = config.transfer.opts.server

-- TODO: fix exit window on click on another win
-- TODO: real-time connection?
-- TODO: add syntax and language support

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- setup data
    U.setup(config)
    LT.setup(config.transfer)
    UI.setup(config.float, config.transfer)
end

function M.toggle()
    vim.g.is_enabled_bufex = not vim.g.is_enabled_bufex

    if not is_server_on and T_server.local_server then
        LT.listen(T_server.host, T_server.port)
        is_server_on = true
    end

    -- close server
    if not vim.g.is_enabled_bufex then
        UI.toggle_window({})
        return
    end

    -- get data from server
    LT.get_buffers(vim.schedule_wrap(function(res, err)
        if err then
            vim.notify(D.messages['ERROR']['RECEIVE'] .. ': ' .. err)

            is_server_on = false
            vim.g.is_enabled_bufex = false

            return
        end

        vim.g.is_enabled_bufex = true
        UI.toggle_window(res)
    end))
end

return M
