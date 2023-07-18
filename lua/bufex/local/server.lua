local U = require('bufex.utils')
local msg = U.messages
local uv = vim.loop
local M = {}

---@alias BoolString 'true'|'false'

---@class Buffers
---@field[1] string buffer content
---@field[2] string buffer name
---@field[3] string|'nil' password
---@field[4] string client name
---@field[5] number client id
---@field[6] BoolString opts: allow_edit
---@field[7] BoolString opts: allow_save

local server = nil

---@param host string
---@param port number
---@return string|nil
function M.listen(host, port)
    ---@type Buffers[]
    local shared_buffers = {}

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

        -- listen for data from client
        client:read_start(function(r_err, data)
            if r_err then
                vim.notify(msg['ERROR']['RECEIVE'] .. ': ' .. r_err)
            elseif data then
                if data == 'GET' then
                    if #shared_buffers == 0 then
                        client:write(vim.inspect({}))
                        return
                    end

                    -- send all buffers
                    local buf_data = {}

                    -- ignore client id
                    for _, buf in pairs(shared_buffers) do
                        buf = U.remove_key(buf, 'client_id')

                        table.insert(buf_data, buf)
                    end

                    client:write(vim.inspect(buf_data))
                else
                    local decoder = loadstring or load
                    local decoded_data = decoder('return ' .. data)()

                    decoded_data['client_id'] = client:fileno()
                    table.insert(shared_buffers, decoded_data)
                end
            else
                local client_id = client:fileno()

                -- delete buffer client send, when they leave
                client:close(function()
                    shared_buffers = vim.tbl_filter(function(buf)
                            return buf['client_id'] ~= client_id
                        end, shared_buffers)
                end)
            end
        end)
    end)

    return nil
end

---@return nil|string
function M.close()
    server:close(function(err)
        if err then
            vim.notify(msg['ERROR']['CLOSE'] .. ': ' .. err)
            return err
        end
    end)
end

return M
