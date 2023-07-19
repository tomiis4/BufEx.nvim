local api = vim.api

api.nvim_create_user_command(
    'BufexToggle',
    require('bufex').toggle,
    {}
)
