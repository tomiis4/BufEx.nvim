<h1 align='center'>
    Buffer Exchange
</h1>

<p align='center'>
    A plugin for effortless buffer sharing between nvim sessions. 
</p>


<hr>

<h3 align='center'> <img src='https://media.discordapp.net/attachments/772927831441014847/1134530149480681472/image.png?width=993&height=497'> </h3>
<h6 align='center'> Colorscheme: dogrun; Font: Hurmit NerdFont Mono </h6>

<hr>


## Usage Local
1. send buffer
    - open BufEx menu
    - select "Send Buffer" window (press `n` to switch between windows)
    - select buffer which you want to send and toggle options
    - <details>
        <summary> preview </summary>
        
        ![send-buffer](https://github.com/tomiis4/BufEx.nvim/assets/87276646/ed2c7b18-f870-4b06-8986-4dd986dbd5a4)
    </details>

2. select buffer
    - open BufEx menu
    - press enter on buffer which you want open
    - <details>
        <summary> preview </summary>
        
        ![select-buffer](https://github.com/tomiis4/BufEx.nvim/assets/87276646/9dca69b4-b4ee-4e55-b8d5-e033b88c9b30)
    </details>


## Usage Global
1. host server
    - create or select TCP (server)[https://github.com/tomiis4/BufEx.nvim/tree/main/servers] and host it
    - in configuration change `port`, `host` and `local_server`
    - follow instructions from (Usage Local)[#usage-local]


## Available transfer servers
- Lua (build-in)
- TypeScript
- GoLang

## Installation

<details>
<summary> Using vim-plug </summary>

```vim
Plug 'tomiis4/BufEx.nvim'
```

</details>

<details>
<summary> Using packer </summary>

```lua
use 'tomiis4/BufEx.nvim'
```

</details>

<details>
<summary> Using lazy </summary>

```lua
{
    'tomiis4/BufEx.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons', -- optional
    },
    lazy = true,
    config = function()
        require('bufex').setup({
            -- config
        })
    end
},
```

</details>


## Setup

```lua
require('bufex').setup()
```

<details>
<summary> Default configuration </summary>

```lua
require('hypersonic').setup({
    local_transfer = {
        ---@type string|nil nil = name will be random selected
        name = nil,

        ---@type string|nil password will need to be entered each time
        password = nil,
        opts = {
            allow_edit = true,
            allow_save = false,

            ---@type 'always'|'never'
            need_password = 'always',
            server = {
                local_transfer = true,
                port = 4200,
                host = '127.0.0.1',
            }
        }
    },
    float = {
        ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
        border = 'rounded',

        ---@type number background blur: 0-100 
        winblend = 0,

        ---@type boolean allow nvim-web-devicons
        icons = true,
        keymap = {
            next_window = 'n',
            quit = 'q',
            opts = {
                toggle_save = 'S',
                toggle_edit = 'E',
                toggle_password = 'P',
                continue = 'C',
            }
        }
    }
}
)
```

</details>


## Creating own transfer server
- create 
    - TCP server
    - variable
        - `array[array[got_data, client_id]]`
- got message `GET`
    - send all `got_data` from variable joined by `,` and all wrapped in `{}`
    - TS example: `'{' + variable.map((buf) => buf[0]).join(',') + '}'`
- other message
    - to variable push `[got_data, client_id]`, client\_id can be anything unique
- user disconected (optional)
    - delte from variable array with client\_id


## File order
```
|  📄 LICENSE
|  📄 README.md
|
+-- 📁 lua
|    \-- 📁 bufex
|       |  📄 config.lua
|       |  📄 data.lua
|       |  📄 init.lua
|       |  📄 utils.lua
|       |
|       +-- 📁 local
|       |      📄 client.lua
|       |      📄 local.lua
|       |      📄 server.lua
|       |
|       \-- 📁 ui
|              📄 float.lua
|              📄 input.lua
|              📄 select.lua
|
\-- 📁 plugin
|      📄 bufex.lua
|
\-- 📁 servers
|      📄 ts/main.ts
|      📄 go/main.go
```


## Contributors

<table>
    <tbody>
        <tr>
            <td align='center' valign='top' width='14.28%'>
                <a href='https://github.com/tomiis4'>
                <img src='https://avatars.githubusercontent.com/u/87276646?v=4' width='50px;' alt='tomiis4'/><br />
                <sub><b> tomiis4 </b></sub><br />
                <sup> founder </sup>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
