local api = vim.api

api.nvim_create_user_command(
    'BufexToggle',
    require('bufex.UI.float').toggle_window,
    {}
)
