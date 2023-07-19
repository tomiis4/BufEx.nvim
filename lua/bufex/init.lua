local config = require('bufex.config')
local is_enabled = false
local D = require('bufex.data')
local U = require('bufex.utils')
local UI = require('bufex.ui.float')
local M = {}


local lt = require('bufex.local.local')
local lt_cfg = config.local_transfer
local lt_server = lt_cfg.opts.server

---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- setup data
    U.setup(config)
    UI.setup(config.float)

    -- try start server
    lt.listen(lt_server.host, lt_server.port)
end

function M.toggle()
    is_enabled = not is_enabled

    -- close server
    if is_enabled == false then
        lt.close()
        UI.toggle_window({})
        vim.print('Window closed')
        return
    end

    -- FIXME: this does not belong there
    -- send buffer 
    lt.send_buffer(lt_cfg, 0) -- 0 for current


    -- get data from server
    lt.get_buffers(lt_cfg, vim.schedule_wrap(function(res, err)
        print('Getting data')
        if err then
            vim.notify(D.messages['ERROR']['RECEIVE'] .. ': ' .. err)
            return
        end

        UI.toggle_window(res)
        print('GOT DATA: ' .. vim.inspect(res))
    end))
end

return M
