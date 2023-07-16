<h1 align='center'>
    Buffer Exchange
</h1>

<p align='center'>
    A plugin for effortless buffer sharing between nvim sessions. 
</p>


### For global, you need yours server

FIXME: types!!

### Server
- store send-buffer-data
    - buf content
    - buf name
    - client name
    - client fileno [get on server]
    - opts save
    - opts edit
- 'GET'
    - send all stored data

### Float menu
- keys
    - `q` = quit
    - `r` = refresh
- everyone try to create server
- connect to the server, msg = 'GET'
    - display as "Received buffer"
