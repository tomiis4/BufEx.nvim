import * as net from 'net';

type Buffer = [string, string]; // [data, client_id]

const port = 4200;
let shared_buffers: Buffer[] = [];

const server = net.createServer((client: net.Socket) => {
    // can't find better solution
    const get_id = () => client.remoteAddress + ':' + client.remotePort

    client.on('data', (data: Buffer) => {
        const msg = data.toString();

        if (msg == 'GET') {
            const result = shared_buffers.map((buf) => buf[0]).join(',')

            client.write(`{${result}}`)
        } else {
            shared_buffers.push([msg, get_id()])
        }
    });

    // handle left users
    client.on('end', () => {
        const client_id = get_id()

        // remove left user shared buffers
        shared_buffers = shared_buffers.filter((v) => {
            return v[1] != client_id
        })
    });

    // handle errors
    client.on('error', (err: Error) => {
        console.error(`Socket error: ${err.message}`);
    });
});


// start server
server.listen(port, () => {
    console.log(`Server started and listening on port ${port}`);
});

// handle server errors
server.on('error', (err: Error) => {
    console.error(`Server error: ${err.message}`);
});
