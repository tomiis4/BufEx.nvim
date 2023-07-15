local local_method = require('bufex.local.local')

local config = require('bufex.config')
local M = {}

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})
end

return M
