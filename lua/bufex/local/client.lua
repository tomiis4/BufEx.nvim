local U = require('bufex.utils')
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
function M.send_data(host, port, data)
    local client = uv.new_tcp()

    client:connect(host, port, function(err)
        if err then
            vim.notify(msg['ERROR']['CONNECT'] .. ': ' .. err)
            return
        end

        -- get data from server
        client:read_start(function(r_err, server_data)
            if r_err then
                vim.notify(msg['ERROR']['RECEIVE'] .. ': ' .. err)
                return
            elseif server_data then
                print('Client: ' .. server_data)
                return 1
            else
                client:close(function ()
                    vim.notify(msg['ERROR']['CONNECT'])
                end)
            end
        end)

        -- send data to server
        if data == 'GET' then
            client:write(data)
        elseif type(data) == 'table' then
            client:write(table.concat(data, U.obj_sep))
        end
    end)

    vim.notify(msg['OK']['CONNECT'])
    return nil
end

return M
