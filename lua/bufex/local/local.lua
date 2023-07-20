local client = require('bufex.local.client')
local server = require('bufex.local.server')
local config = require('bufex.config').local_transfer

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

---@param callback fun(res: Buffers[], err: string|nil)
function M.get_buffers(callback)
    local opts = config.opts.server

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

---@param buf_id number
function M.send_buffer(buf_id)
    local opts = config.opts.server

    local buf_name = api.nvim_buf_get_name(buf_id):match('[^\\/]+$') or ''
    local buf_content = api.nvim_buf_get_lines(buf_id, 0, -1, false)

    if buf_content == '' then return end

    ---@class Data
    local data = {
        content = table.concat(buf_content, '\n'),
        buffer_name = buf_name,
        password = config.password,
        client_name = config.name or U.get_random_name(),
        allow_edit = config.opts.allow_edit,
        allow_save = config.opts.allow_save,
    }

    client.send_data(
        opts.host,
        opts.port,
        vim.inspect(data),
        vim.schedule_wrap(function (_, err)
            vim.notify(err)
        end)
    )
end

M.listen = server.listen
M.close = server.close

---@param cfg LocalTransfer
function M.setup(cfg)
    config = cfg
end

return M
