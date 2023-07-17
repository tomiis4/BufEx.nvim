local local_method = require('bufex.local.local')
local UI = require('bufex.ui.float')

local config = require('bufex.config')
local api = vim.api
local U = require('bufex.utils')
local M = {}

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})
    UI.setup(config.float)

    UI.toggle_window()

    api.nvim_create_autocmd('VimResized', {
        callback = function ()
            UI.redraw()
        end
    })
end

return M
