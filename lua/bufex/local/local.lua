local client = require('bufex.local.client')
local server = require('bufex.local.server')

local api = vim.api
local U = require('bufex.utils')
local M = {}

---@class SeparatedBuffers
---@field buffer_content string
---@field buffer_name string
---@field password string|nil
---@field client_name string
---@field allow_edit boolean
---@field allow_save boolean

---@param cfg LocalTransfer
---@param callback fun(res: SeparatedBuffers[], err: string|nil)
function M.get_buffers(cfg, callback)
    local opts = cfg.opts.server

    client.send_data(opts.host, opts.port, 'GET', function(res, err)
        if err and callback then
            callback({}, err)
            return
        end

        ---@type SeparatedBuffers[]
        local buffers = {}

        -- loop trough each buffer
        for _, obj in pairs(vim.split(res, U.new_obj_sep)) do
            local values = vim.split(obj, U.obj_sep)

            table.insert(buffers, {
                buffer_content = values[1],
                buffer_name = values[2],
                password = U.fix_type(values[3]),
                client_name = values[4],
                allow_edit = U.fix_type(values[5]),
                allow_save = U.fix_type(values[6]),
            })
        end

        if callback then
            callback(buffers, nil)
        end
    end)
end

---@param cfg LocalTransfer
function M.send_buffer(cfg)
    local opts = cfg.opts.server

    local buf_name = api.nvim_buf_get_name(0):match('[^\\/]+$') or ''
    local buf_content = api.nvim_buf_get_lines(0, 0, -1, false)

    ---@class Data
    local data = {
        table.concat(buf_content, '\n'),
        buf_name,
        cfg.password or 'nil',
        cfg.name or U.get_random_name(),
        tostring(cfg.opts.allow_edit),
        tostring(cfg.opts.allow_save),
    }

    client.send_data(
        opts.host,
        opts.port,
        table.concat(data, U.obj_sep)
    )
end

M.listen = server.listen
M.close = server.close

return M
