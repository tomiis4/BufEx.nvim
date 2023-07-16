local api = vim.api
local U = {}

local names = { 'Lion', 'Elephant', 'Tiger', 'Giraffe', 'Monkey', 'Dolphin', 'Penguin', 'Koala', 'Cheetah', 'Gorilla' }

U.obj_sep = 'DATA_SEPARATOR'
U.new_obj_sep = 'NEW_OBJ_SEPARATOR'
U.messages = {
    ['OK'] = {
        ['CONNECT'] = 'Connection was established successfully.',
        ['CREATE'] = 'Server was created successfully.',
        ['CLOSE'] = 'Server was closed successfully.',
        ['SEND'] = 'Data was sent successfully.',
        ['RECEIVE'] = 'Data was received successfully.',
    },
    ['ERROR'] = {
        ['CONNECT'] = 'Failed to establish connection.',
        ['CREATE'] = 'Failed to create server.',
        ['CLOSE'] = 'Failed to close server.',
        ['SEND'] = 'Failed to send data.',
        ['RECEIVE'] = 'Failed to receive data.',
    }
}

---@return string
function U.get_random_name()
    math.randomseed(os.time())
    return names[math.random(1, #names)]
end

---@param s string
---@return any
function U.fix_type(s)
    return (s == 'nil' and nil)
        or (s == 'true' and true)
        or (s == 'false' and false)
        or tonumber(s)
        or s
end

---@param display_icon boolean
---@return table
function U.get_buffers(display_icon)
    local data = {}

    local bufs = api.nvim_list_bufs()
    bufs = vim.tbl_filter(function(buf)
        local is_loaded = api.nvim_buf_is_loaded(buf)
        local is_listed = vim.fn.buflisted(buf) == 1

        if not (is_loaded and is_listed) then
            return false
        end

        return true
    end, bufs)

    for _, buf in pairs(bufs) do
        local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
        local ext = string.match(name, "%w+%.(.+)") or name
        local icon = U.get_icon(name, ext, display_icon)

        if name ~= "" then
            table.insert(data, icon .. " " .. name)
        end
    end

    return data
end

---@param name string
---@param ext string
---@param display boolean
---@return string
function U.get_icon(name, ext, display)
    local ok, dev_icons = pcall(require, 'nvim-web-devicons')

    if not display then
        return ' '
    end

    if not ok then
        return ''
    end

    local icon = dev_icons.get_icon(name, ext, { default = true })
    return icon
end

---@param buf number
---@param key string
---@param action string|function
---@param mode string? default 'n'
---@param opts table?
function U.keyset(buf, key, action, mode, opts)
    opts = opts or { nowait = true, silent = true }
    mode = mode or 'n'

    api.nvim_buf_set_keymap(buf, mode, key, action, opts)
end

return U
