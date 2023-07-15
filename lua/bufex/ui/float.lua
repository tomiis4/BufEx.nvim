local api = vim.api
local M = {}
--[[


|------------------| |------------------|
| Send buffer      | | Receive buffer   |
|------------------| |------------------|
| 1) index.js      | | 1) index.js      |
| 2) README.md     | |    - tomiis4     |
| 3) style.css     | |    - edit, save  |
|                  | |    - password    |
|                  | |                  |
|------------------| |------------------|


|---------------------------------------|
| Send buffer                           |
|---------------------------------------|
| - index.js                            |
|   - edit = TRUE                       |
|   - save = FALSE                      |
|   - password = FALSE                  |
|                                       |
|---------------------------------------|


|-Enter password------------------------|
|                                       |
|---------------------------------------|


]]

--- TODO: content
---@param config Float
function M.create_window(config, content)
end

return M
