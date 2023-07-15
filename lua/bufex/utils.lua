local U = {}

local names = { 'Lion', 'Elephant', 'Tiger', 'Giraffe', 'Monkey', 'Dolphin', 'Penguin', 'Koala', 'Cheetah', 'Gorilla' }

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

U.obj_sep = 'DATA_SEPARATOR'
U.new_obj_sep = 'NEW_OBJ_SEPARATOR'

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

---@param tbl table
---@param n number? number of indents (default 0)
---@return nil
function U.print_table(tbl, n)
    n = n or 0

    print(string.rep('|   ', n) .. '{')

    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            U.print_table(v, n + 1)
        else
            print(string.rep('|   ', n + 1) .. v .. ',')
        end
    end
    print(string.rep('|   ', n) .. '},')
end

return U
