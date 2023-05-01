package main

import "core:fmt"

Ship :: struct {
  position:       Vector2d
  velocity:       Vector2d
  hit_radius:     f32
  size:           f32
  turn:           int
  acceleration:   int
  lives:          int
  local_vertices: [3]Vector2d
  world_vertices: [3]Vector2d
}

Bullet :: struct {
  position: Vector2d
  velocity: Vector2d
  alive:    bool
}

SHIP_MAXSPEED :: 2
SHIP_SIZE     :: 20
SHIP_LIVES    :: 3

init_ship :: proc(ship: ^Ship) {

  ship.size = SHIP_SIZE
  ship.position = Vector2d{500, 500}
  ship.lives = SHIP_LIVES

  offset := ship.size/1.5

  ship.hit_radius = SHIP_SIZE * 0.6

  ship.local_vertices[0] = Vector2d{      0, -ship.size}
  ship.local_vertices[1] = Vector2d{ offset,  ship.size}
  ship.local_vertices[2] = Vector2d{-offset,  ship.size}

}

draw_ship :: proc(ship: ^Ship, color: u32, view: ^View) {
  if ship.lives > 0 {
    draw_line(int(ship.world_vertices[0][0]),int(ship.world_vertices[0][1]),
              int(ship.world_vertices[1][0]),int(ship.world_vertices[1][1]),
              color, view)
    draw_line(int(ship.world_vertices[1][0]),int(ship.world_vertices[1][1]),
              int(ship.world_vertices[2][0]),int(ship.world_vertices[2][1]),
              color, view)
    draw_line(int(ship.world_vertices[2][0]),int(ship.world_vertices[2][1]),
              int(ship.world_vertices[0][0]),int(ship.world_vertices[0][1]),
              color, view)
  }
}

update_ship :: proc(ship: ^Ship, view: ^View) {
  Vector2d_limit(&ship.velocity, SHIP_MAXSPEED)
  ship.position += ship.velocity

  bound_position(&ship.position, ship.hit_radius, view) 

  for i := 0; i < len(ship.world_vertices); i += 1{
    ship.world_vertices[i] = ship.local_vertices[i] + ship.position
  }
}
rotate_ship :: proc(ship: ^Ship, amount: f32) {
  for i := 0; i < len(ship.local_vertices); i += 1 {
    Vector2d_rotate(&ship.local_vertices[i], amount)
  }
}
apply_force :: proc(velocity, extra: ^Vector2d) {
  velocity^ += extra^
}
shoot_bullet :: proc() {}

