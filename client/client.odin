package client

import NET "core:net"
import FMT "core:fmt"

ADDRESS :: "127.0.0.1"
PORT :: 7777

BYTES :: []u8{1,2,3,4}

main :: proc() {
  err : NET.Network_Error
  socket : NET.UDP_Socket
  bytesWritten : int

  address := NET.parse_address(ADDRESS)
  endpoint := NET.Endpoint {
    address,
    PORT
  }

  socket, err = NET.make_unbound_udp_socket(NET.Address_Family.IP4)

  FMT.println(socket)
  FMT.println(err)

  bytesWritten, err = NET.send_udp(socket, BYTES, endpoint)
  FMT.println(bytesWritten)

  NET.close(socket)
}
