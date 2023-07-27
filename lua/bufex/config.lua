---@alias Option 'always'|'never'
---@alias BorderType 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table

---@class Server
---@field local_server boolean default true
---@field port number default 4200
---@field host string default '127.0.0.1'

---@class Opts
---@field allow_edit boolean default true
---@field allow_save boolean default false
---@field need_password Option default 'always'
---@field server Server

---@class OptsKeymap
---@field toggle_save string default 'S'
---@field toggle_edit string default 'E'
---@field toggle_password string default 'P'
---@field continue string default 'C'

---@class Keymap
---@field quit string default 'q'
---@field next_window string default 'n'
---@field opts OptsKeymap

---@class LocalTransfer
---@field name string|nil default nil (name will be generated random)
---@field password string|nil default nil (password will be generated random)
---@field opts Opts

---@class Float
---@field border BorderType default 'rounded'
---@field winblend number range 0-100, default 0
---@field icons boolean default true
---@field keymap Keymap

---@class Configuration
---@field local_transfer LocalTransfer
---@field float Float

---@type Configuration
local cfg = {
    local_transfer = {
        name = nil,
        password = nil,
        opts = {
            allow_edit = true,
            allow_save = false,
            need_password = 'always',
            server = {
                local_server = true,
                port = 4200,
                host = '127.0.0.1'
            }
        }
    },
    float = {
        border = 'rounded',
        winblend = 0,
        icons = true,
        keymap = {
            quit = 'q',
            next_window = 'n',

            opts = {
                toggle_save = 'S',
                toggle_edit = 'E',
                toggle_password = 'P',
                continue = 'C',
            }
        }
    }
}

return cfg
