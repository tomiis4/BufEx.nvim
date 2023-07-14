local config = require('bufex.config')

local client = require('bufex.api.client')
local server = require('bufex.api.server')

local api = vim.api
local U = require('bufex.utils')
local M = {}


function M.send_buffer()
    local cfg_local = config.local_transfer
    local cfg_opts = cfg_local.opts
    local cfg_server = cfg_opts.server

    -- start server
    local s_err = server.listen(cfg_server.host, cfg_server.port)
    if s_err then return end

    -- get data
    local buf_name = api.nvim_buf_get_name(0):match("[^\\/]+$") or ""
    local buf = api.nvim_buf_get_lines(0, 0, -1, false)
    local data = {
        table.concat(buf, '\n'),
        buf_name,
        cfg_local.password or 'nil',
        cfg_local.name or U.get_random_name(),
        tostring(cfg_opts.allow_edit),
        tostring(cfg_opts.allow_save),
    }
    -- local data = {
    --     buffer = buf,
    --     buffer_name = buf_name,
    --     password = cfg_local.password,
    --     owner = cfg_local.name or U.get_random_name(),
    --     opts = {
    --         allow_edit = cfg_opts.allow_edit,
    --         allow_save = cfg_opts.allow_save,
    --     }
    -- }

    -- connect to the server
    local conn_err = client.connect_and_send(
            cfg_server.host,
            cfg_server.port,
            data
        )

    if conn_err then print("err") end

    -- print('closing')
    -- ??close server??
    -- server.close()
end

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    M.send_buffer()
end

M.server = server
M.client = client

return M
