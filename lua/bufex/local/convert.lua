-- DELETE THIS FILE

local M = {}

---@param str string
---@return table
function M.decode(str)
    local load_function = loadstring or load 
    local data_table = load_function("return " .. str)()
    vim.print(data_table)
    return {}
end

---@param tbl table
---@return string
function M.encode(tbl)
    return vim.inspect(tbl, { compact = true })
end

return M
