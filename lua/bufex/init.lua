local local_method = require('bufex.local.local')
local UI = require('bufex.ui.float')

local config = require('bufex.config')
local U = require('bufex.utils')
local M = {}

function Display(res, err)
    if err then
        print(U.messages['ERROR']['RECEIVE'])
    else
        print(vim.inspect(res))
    end
end

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- stimulate opening window WORKING
    local local_opts = config.local_transfer.opts
    local_method.listen(local_opts.server.host, local_opts.server.port)
    local_method.send_buffer(config.local_transfer)

    UI.select_buffer(config.float, U.get_buffers(config.float.icons))
    local_method.get_buffers(config.local_transfer, function (res, err)
        if err then
            print(U.messages['ERROR']['RECEIVE'])
        else
            UI.receive_buffer(config.float, res)
        end
    end)

    -- stimulate opening window WORKING
    -- local local_opts = config.local_transfer.opts
    -- local_method.listen(local_opts.server.host, local_opts.server.port)
    -- local_method.send_buffer(config.local_transfer)
    -- local_method.send_buffer(config.local_transfer)
    -- local_method.get_buffers(config.local_transfer, function(res, err)
    --     if err then
    --         vim.notify(U.messages['ERROR']['RECEIVE'])
    --     else
    --         print(vim.inspect(res))
    --     end
    -- end)
end

return M
