local client = require('bufex.local.client')
local server = require('bufex.local.server')

local api = vim.api
local U = require('bufex.utils')
local M = {}

---@class Buffers
---@field content string
---@field buffer_name string
---@field password string|nil
---@field client_name string
---@field allow_edit boolean
---@field allow_save boolean

---@param cfg LocalTransfer
---@param callback fun(res: Buffers[], err: string|nil)
function M.get_buffers(cfg, callback)
    local opts = cfg.opts.server

    client.send_data(opts.host, opts.port, 'GET', function(res, err)
        if err and callback then
            callback({}, err)
            return
        end

        if callback then
            local decoder = loadstring or load
            local decoded = decoder('return ' .. res)()

            callback(decoded, nil)
        end
    end)
end

---@param cfg LocalTransfer
---@param buf_id number
function M.send_buffer(cfg, buf_id)
    local opts = cfg.opts.server

    local buf_name = api.nvim_buf_get_name(buf_id):match('[^\\/]+$') or ''
    local buf_content = api.nvim_buf_get_lines(buf_id, 0, -1, false)

    ---@class Data
    local data = {
        content = table.concat(buf_content, '\n'),
        buffer_name = buf_name,
        password = cfg.password,
        client_name = cfg.name or U.get_random_name(),
        allow_edit = cfg.opts.allow_edit,
        allow_save = cfg.opts.allow_save,
    }

    client.send_data(
        opts.host,
        opts.port,
        vim.inspect(data)
    )
end

M.listen = server.listen
M.close = server.close

return M
