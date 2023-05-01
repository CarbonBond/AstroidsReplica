package main

Ship :: struct {
  position: Vector2d
  size: f32
  turn: int
  acceleration: int
  speed: int
}

draw_ship :: proc(ship: ^Ship, color: u32, view: ^View) {
  x1, y1, x2, y2, x3, y3 : int 

  offset := ship.size/1.5
  x1 = int( ship.position.x )
  y1 = int( -ship.size + ship.position.y )

  x2 = int( offset + ship.position.x )
  y2 = int( ship.size + ship.position.y)

  x3 = int( -(offset) + ship.position.x )
  y3 = y2 

  
  draw_line(x1, y1, x2, y2, color, view) 
  draw_line(x2, y2, x3, y3, color, view) 
  draw_line(x3, y3, x1, y1, color, view) 
}

