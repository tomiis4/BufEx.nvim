local msg = require('bufex.utils').messages

local uv = vim.loop
local M = {}

---@class Data everything is string tho
---@field[1] table<string> buffer
---@field[2] string buffer_name
---@field[3] string|nil password
---@field[4] string owner
---@field[5] boolean allow_edit
---@field[6] boolean allow_save


---@param host string
---@param port number
---@param data Data|string
---@return table|nil
function M.send_data(host, port, data, callback)
    local client = uv.new_tcp()

    -- connect to server
    client:connect(host, port, function(err)
        if err then
            vim.notify(msg['ERROR']['CONNECT'] .. ': ' .. err)
            if callback then
                callback(nil, err)
            end
            return
        end

        -- get data from server
        client:read_start(function(r_err, server_data)
            if r_err then
                vim.notify(msg['ERROR']['RECEIVE'] .. ': ' .. err)
                if callback then
                    callback(nil, r_err)
                end
                return
            elseif server_data and callback then
                callback(server_data, nil)
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