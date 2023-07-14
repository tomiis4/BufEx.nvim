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
---@param data Data
---@return string|nil
function M.connect_and_send(host, port, data)
    local client = uv.new_tcp()

    client:connect(host, port, function(err)
        if err then
            vim.notify(msg['ERROR']['CONNECT'] .. ': ' .. err)
            return err
        end

        client:read_start(function(_, server_data)
            if server_data then
                vim.print('Received from server: ' .. server_data)
            else
                client:close()
            end
        end)

        -- send data to server
        client:write(data)
    end)

    vim.notify(msg['OK']['CONNECT'])
    return nil
end

return M
