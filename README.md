<h1 align='center'>
    !NOT READY FOR USE!<br>Buffer Exchange
</h1>

<p align='center'>
    A plugin for effortless buffer sharing between nvim sessions. 
</p>


<hr>

<h3 align="center"> <img src='#'> </h3>
<h6 align="center"> Colorscheme: dogrun; Font: Hurmit NerdFont Mono </h6>

<hr>


## Usage
1. method
    - explanation
    - <details>
        <summary> preview </summary>
        <img src='#'>
    </details>

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
                port = 4200,
                host = '127.0.0.1'
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
       📄 bufex.lua
```


## Contributors

<table>
    <tbody>
        <tr>
            <td align="center" valign="top" width="14.28%">
                <a href="https://github.com/tomiis4">
                <img src="https://avatars.githubusercontent.com/u/87276646?v=4" width="50px;" alt="tomiis4"/><br />
                <sub><b> tomiis4 </b></sub><br />
                <sup> founder </sup>
                </a><br/>
            </td>
        </tr>
    </tbody>
</table>
