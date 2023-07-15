local client = require('bufex.local.client')
local server = require('bufex.local.server')

local api = vim.api
local U = require('bufex.utils')
local M = {}

---@param cfg LocalTransfer
function M.get_buffers(cfg, callback)
    local opts = cfg.opts.server

    client.send_data(opts.host, opts.port, 'GET', function(res, err)
        if err and callback then
            vim.notify(U.messages['ERROR']['RECEIVE'])
            callback(nil, err)
            return
        end

        local buffers = {}

        -- loop trough each buffer
        for _, obj in pairs(vim.split(res, U.new_obj_sep)) do
            local buf = {}

            -- loop trough each value in buffer
            for _, value in pairs(vim.split(obj, U.obj_sep)) do
                table.insert(buf, U.fix_type(value))
            end
            table.insert(buffers, buf)
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
