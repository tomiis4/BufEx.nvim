local msg = require('bufex.data').messages

local uv = vim.loop
local M = {}


---@param host string
---@param port number
---@param data 'get'|string
---@param callback fun(res: Buffers[], err: string|nil)
---@return table|nil
function M.send_data(host, port, data, callback)
    local client = uv.new_tcp()

    -- connect to server
    client:connect(host, port, function(err)
        if err then
            if callback then
                callback({}, err)
            end
            return
        end

        -- get data from server
        client:read_start(function(r_err, server_data)
            if r_err then
                vim.notify(msg['ERROR']['RECEIVE'] .. ': ' .. err)
                callback({}, r_err)

                client:close()
                return
            elseif server_data and callback then
                callback(server_data, nil)
                print('Client has closed')
            else
                -- server is closed
                client:close(function()
                    vim.notify(msg['ERROR']['CONNECT'])
                end)
            end
        end)

        -- send data to server
        client:write(data)
    end)
end

return M
