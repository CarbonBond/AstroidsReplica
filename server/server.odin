package server

import NET "core:net"
import FMT "core:fmt"

ADDRESS :: "127.0.0.1"
PORT :: 7777

main :: proc() {
  socket   : NET.UDP_Socket
  err      : NET.Network_Error
  address  := NET.parse_address(ADDRESS)

  socket, err = NET.make_bound_udp_socket(address, PORT)

  buffer    := []u8{0,0,0,0}
  bytesRead : int
  endPoint  : NET.Endpoint
  
  for {
    bytesRead, endPoint, err = NET.recv_udp(socket, buffer)
    if(bytesRead > 0) do break
  }
  FMT.println(buffer)
  NET.close(socket)
}
