local U = require('bufex.utils')
local D = require('bufex.data')
local msg = D.messages
local uv = vim.loop
local M = {}

local server = nil

---@param host string
---@param port number
---@return string|nil
function M.listen(host, port)
    ---@type table<table<string, number>>
    local shared_buffers = {}
    local connections = {}

    -- create server
    server = uv.new_tcp()
    server:bind(host, port)

    -- listen for connections
    server:listen(128, function(err)
        if err then
            vim.notify(msg['ERROR']['CREATE'] .. ': ' .. err)
            return err
        end

        local client = uv.new_tcp()

        server:accept(client)
        table.insert(connections, client)

        -- listen for data from client
        client:read_start(function(r_err, data)
            if r_err then
                return r_err
            elseif data then
                if data == 'GET' then
                    if #shared_buffers == 0 then
                        client:write(vim.inspect({}))
                        return
                    end

                    -- send all buffers
                    local buf_data = {}

                    -- ignore client id (idx 2)
                    for _, buf in pairs(shared_buffers) do
                        table.insert(buf_data, buf[1])
                    end

                    client:write('{' .. table.concat(buf_data, ',') .. '}')
                else
                    -- local decoder = loadstring or load
                    -- local decoded_data = decoder('return ' .. data)()

                    -- decoded_data['client_id'] = client:fileno()
                    table.insert(shared_buffers, {
                        data, client:fileno()
                    })

                    -- TODO: implement real-time conenction
                    -- for _, user in pairs(connections) do
                    --     user:write('Someone connected to the server')
                    -- end
                end
            else
                local client_id = client:fileno()

                -- delete buffer client send, when they leave
                client:close(function()
                    shared_buffers = vim.tbl_filter(function(buf)
                            return buf[2] ~= client_id
                        end, shared_buffers)
                end)
            end
        end)
    end)

    return nil
end

---@return nil|string
function M.close()
    server:close()
    server = nil
end

return M
