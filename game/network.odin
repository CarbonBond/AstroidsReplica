package main

import NET "core:net"
import STR "core:strings"
import STRC "core:strconv"
import FMT "core:fmt"


BYTES :: []u8{1,2,3,4}

Connection :: struct{
  socket: NET.UDP_Socket
  endpoint: NET.Endpoint
}

Receiver :: struct {
  connection: Connection
  name:       string
  id:         int
}

SERVER :: #config (SERVER,false)

create_connection :: proc(port: int, ip: string) -> ^Connection {
  err : NET.Network_Error
  socket : NET.UDP_Socket

  address := NET.parse_address(ip)
  endpoint := NET.Endpoint {
    address,
    port
  }

  connection := new(Connection)
  connection.endpoint = endpoint

  socket, err := NET.make_bound_udp_socket(address, PORT)
  connection.socket = socket

  return connection
}


send_data :: proc(connection: ^Connection, buffer: []u8) {
  bytesWritten : int
  for bytesWritten < len(buffer) {
    data := buffer[bytesWritten:]
    sentData, err := NET.send_udp(connection.socket, data, connection.endpoint)
    bytesWritten += sentData
  }
}

receive_data :: proc(connection: ^Connection, buffer: []u8, id: int) -> receiver {
  receive : receiver
  FMT.println("trying to get data")
  bytesRead, endpoint, err := NET.recv_udp(connection.socket, buffer)
  receive.endpoint = endpoint

  temp : [10]byte
  name  : [2]string
  name[0] = NET.address_to_string(endpoint.address)
  name[1] = STRC.itoa(temp[:], endpoint.port)
  receive.name = STR.concatenate(name[:]) 
  receive.id = id
  return receive
}

close_connection ::proc(connection: ^Connection) {
  NET.close(connection.socket)
}
