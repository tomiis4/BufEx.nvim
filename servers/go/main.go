package main

import (
	"fmt"
	"net"
	"strings"
)

type Buffer struct {
	Data     string
	ClientID string
}

const (
	HOST = "127.0.0.1"
	PORT = "4200"
)

var sharedBuffers []Buffer

func main() {
	server, err := net.Listen("tcp", HOST+":"+PORT)
	if err != nil {
		fmt.Printf("Error starting the server: %s\n", err)
		return
	}

	fmt.Printf("Server started and listening on port %s\n", PORT)

	for {
		client, err := server.Accept()
		if err != nil {
			fmt.Printf("Error accepting clientection: %s\n", err)
			continue
		}
		go handleConnection(client)
	}
}

func handleConnection(client net.Conn) {
	defer client.Close()

	clientID := client.RemoteAddr().String()
	buffer := make([]byte, 1024)

	for {
		n, err := client.Read(buffer)
		if err != nil {
			fmt.Printf("Error reading data: %s\n", err)
			return
		}

		msg := string(buffer[:n])

		if msg == "GET" {
			result := make([]string, len(sharedBuffers))
			for i, buf := range sharedBuffers {
				result[i] = buf.Data
			}
			response := "{" + strings.Join(result, ",") + "}"
			client.Write([]byte(response))
		} else {
			sharedBuffers = append(sharedBuffers, Buffer{Data: msg, ClientID: clientID})
		}
	}
}
