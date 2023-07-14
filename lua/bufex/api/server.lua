local msg = require('bufex.utils').messages
local uv = vim.loop
local M = {}

local server

---@param host string
---@param port number
---@return string|nil
function M.listen(host, port)
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
        client:read_start(function(_, data)
            if data then
                client:write(data)
            else
                -- client:close()
            end
        end)
    end)

    vim.notify(msg['OK']['CREATE'])
    return nil
end

function M.close()
    server:close(function(err)
        server = nil

        if err then
            vim.notify(msg['ERROR']['CLOSE'] .. ': ' .. err)
            return
        end
    end)

    vim.notify(msg['OK']['CLOSE'])
end

return M
