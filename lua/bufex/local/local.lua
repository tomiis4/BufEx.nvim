local client = require('bufex.local.client')
-- local server = require('bufex.local.server')

local api = vim.api
local U = require('bufex.utils')
local M = {}

---@param cfg LocalTransfer
function M.get_buffers(cfg)
    local opts = cfg.opts.server
    -- local buffers = {}

    local buffers = client.send_data(opts.host, opts.port, 'GET')

    return vim.split(buffers, U.obj_sep)
end

---@param cfg LocalTransfer
function M.send_buffer(cfg)
    local opts = cfg.opts.server

    local buf_name = api.nvim_buf_get_name(0):match('[^\\/]+$') or ''
    local buf_content = api.nvim_buf_get_lines(0, 0, -1, false)

    local data = {
        table.concat(buf_content, '\n'),
        buf_name,
        cfg.password,
        cfg.name or U.get_random_name(),
        cfg.opts.allow_edit,
        cfg.opts.allow_save,
    }

    client.send_data(
        opts.host,
        opts.port,
        table.concat(data, U.obj_sep)
    )
end

return M
