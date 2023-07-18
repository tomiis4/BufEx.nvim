local api = vim.api
local ns = api.nvim_create_namespace('BufEx')

local config = require('bufex.config')
local float = config.float

local D = require('bufex.data')
local U = {}


---@class HL
---@field[1] number line
---@field[2] string color

---@class Size
---@field width number
---@field height number


---@return string
function U.get_random_name()
    math.randomseed(os.time())
    return D.names[math.random(1, #D.names)]
end

---@return string icon
---@return string color
function U.get_icon(file)
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')
    local ext = file:match('%w+%.(.+)') or file

    -- icons disabled
    if not float.icons then
        return ' ', ''
    end

    -- can't find dev-icons
    if not ok then
        return '', ''
    end

    return dev_icons.get_icon(file, ext, { default = true })
end

---@return table buffers
---@return HL[] highlights
function U.get_all_buffers()
    local buffers = {}
    local hl = {} ---@type HL[]

    -- filter existing buffers
    local bufs = api.nvim_list_bufs()
    bufs = vim.tbl_filter(function(buf)
            local is_loaded = api.nvim_buf_is_loaded(buf)
            local is_listed = vim.fn.buflisted(buf) == 1

            if not (is_loaded and is_listed) then
                return false
            end

            return true
        end, bufs)

    -- add icons
    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match('[^\\/]+$') or ''
        local icon, color = U.get_icon(name)

        if name ~= '' then
            table.insert(buffers, icon .. ' ' .. name)

            -- add to line
            table.insert(hl, { #buffers - 1, color })
        end
    end

    return buffers, hl
end

---@param title string
---@param position 'left'|'right'|'center'
---@param size Size width-height in %
---@param lines table
---@return number buffer
---@return number window
function U.setup_win_buf(title, position, size, lines)
    -- setup buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local pos = D.get_win_size(position, size)

    -- create window
    local win_opts = {
        relative = 'editor',
        width = pos.width,
        height = pos.height,
        row = pos.row,
        col = pos.col,
        title = string.format(' %s ', title),
        title_pos = 'center',
        style = 'minimal',
        border = float.border,
    }

    local win = api.nvim_open_win(buf, false, win_opts)

    -- configure window
    api.nvim_win_set_option(win, 'winblend', float.winblend)
    api.nvim_set_option_value('modifiable', false, { buf = buf })
    api.nvim_set_option_value('buflisted', false, { buf = buf })

    -- add hl
    for i = 0, #lines do
        api.nvim_buf_add_highlight(buf, ns, 'Normal', i, 0, -1)
    end
    api.nvim_set_option_value('winhighlight', 'FloatBorder:Normal', { win = win })

    -- add keymaps
    U.keyset(buf, float.keymap.quit, ':BufexToggle<cr>')

    return buf, win
end

function U.init(cfg)
    config = cfg
end

return U
