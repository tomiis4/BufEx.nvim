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

return U
