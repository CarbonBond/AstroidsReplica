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

Reciever :: struct {
  endpoint: NET.Endpoint
  name:     string
  id:       int
}

SERVER :: #config (SERVER,false)

create_connection :: proc(port: int, ip: string) -> ^Connection {
  err : NET.Network_Error
  socket : NET.UDP_Socket

  address := NET.parse_address(ip)
  endpoint := NET.Endpoint {
    address,
    PORT
  }

  connection := new(Connection)
  connection.endpoint = endpoint

  when SERVER {
    connection.socket = create_server(connection.endpoint)
  }
  else {
    connection.socket = create_client()
  }

  return connection
}

create_server :: proc(endpoint: NET.Endpoint) -> NET.UDP_Socket{
  socket, err := NET.make_bound_udp_socket(endpoint.address, endpoint.port)
  return socket
}
create_client :: proc() -> NET.UDP_Socket {
  socket, err := NET.make_unbound_udp_socket(NET.Address_Family.IP4)
  return socket
}


send_data :: proc(connection: ^Connection, buffer: []u8) {
  bytesWritten : int
  for bytesWritten < len(buffer) {
    data := buffer[bytesWritten:]
    sentData, err := NET.send_udp(connection.socket, data, connection.endpoint)
    bytesWritten += sentData
  }
}

recieve_data :: proc(connection: ^Connection, buffer: []u8) -> Reciever {
  recieve : Reciever
  bytesRead, endpoint, err := NET.recv_udp(connection.socket, buffer)
  recieve.endpoint = endpoint

  temp : [10]byte
  name  : [2]string
  name[0] = NET.address_to_string(endpoint.address)
  name[1] = STRC.itoa(temp[:], endpoint.port)
  recieve.name = STR.concatenate(name[:]) 
  return recieve
}

close_connection ::proc(connection: ^Connection) {
  NET.close(connection.socket)
}
