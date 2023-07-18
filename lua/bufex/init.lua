local config = require('bufex.config')
local is_enabled = false
local U = require('bufex.utils')
local M = {}


---@param opts? Configuration
function M.setup(opts)
    ---@type Configuration
    config = vim.tbl_deep_extend('force', config, opts or {})

    -- setup utils
    U.init(config)
end

local lt = require('bufex.local.local')
local lt_cfg = config.local_transfer
local lt_server = lt_cfg.opts.server

function M.toggle()
    is_enabled = not is_enabled

    -- try start server
    lt.listen(lt_server.host, lt_server.port)

    -- close server
    if not is_enabled then
        lt.close()
        return
    end

    -- toggle ui
    -- TODO
    lt.send_buffer(lt_cfg, 0) -- 0 for current

    -- get data from server
    -- TODO err, types
    lt.get_buffers(lt_cfg, vim.schedule_wrap(function(res, err)
        vim.print(vim.inspect(res[1]['allow_edit']))
    end))
end

return M
