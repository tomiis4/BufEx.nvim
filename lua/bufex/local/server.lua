local U = require('bufex.utils')
local msg = U.messages
local uv = vim.loop
local M = {}

---@param host string
---@param port number
---@return string|nil
function M.listen(host, port)
    local shared_buffers = {}

    -- create server
    local server = uv.new_tcp()
    server:bind(host, port)

    -- listen for connections
    server:listen(128, function(err)
        if err then
            vim.notify(msg['ERROR']['CREATE'] .. ': ' .. err)
            return err
        end

        local client = uv.new_tcp()
        server:accept(client)

        -- listen for data from client
        client:read_start(function(r_err, data)
            if r_err then
                vim.notify(msg['ERROR']['RECEIVE'] .. ': ' .. r_err)
            elseif data then
                if data == 'GET' then
                    -- send all buffers
                    local buf_data = {}

                    for _, v in pairs(shared_buffers) do
                        table.insert(buf_data, table.concat(v, U.obj_sep))
                    end

                    client:write(table.concat(buf_data, U.new_obj_sep))
                else
                    local separated = vim.split(data, U.obj_sep)

                    -- write all buffers
                    table.insert(shared_buffers, {
                        separated[1], -- buffer content
                        separated[2], -- buffer name
                        separated[3], -- password
                        separated[4], -- client_name
                        client:fileno(), -- client_id
                        separated[5], -- opts: allow_edit
                        separated[6], -- opts: allow_save
                        separated[7], -- opts: allow_save
                    })
                end
            else
                local client_id = client:fileno()

                -- delete buffer client send, when they leave
                client:close(function ()
                    shared_buffers = vim.tbl_filter(function(buf)
                        return buf[5] ~= client_id
                    end, shared_buffers)
                end)
            end
        end)
    end)

    vim.notify(msg['OK']['CREATE'])
    return server
end

function M:close(handle)
    handle:close(function(err)
        if err then
            vim.notify(msg['ERROR']['CLOSE'] .. ': ' .. err)
            return
        end
    end)

    vim.notify(msg['OK']['CLOSE'])
end

return M
