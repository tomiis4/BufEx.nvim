local config = require('bufex.config')
local U = require('bufex.utils')
local M = {}


---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- setup utils
    U.init(config)

    -- testing server/client
    -- local l = require('bufex.local.local')
    --
    -- l.listen('127.0.0.1', 6969)
    --
    -- l.get_buffers(config.local_transfer, vim.schedule_wrap(function(res, err)
    --
    --     local buf = vim.api.nvim_create_buf(false, true)
    --     print(buf)
    -- end))
end

return M
