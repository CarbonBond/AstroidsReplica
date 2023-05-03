package main

import "core:fmt"

SHIP_MAXSPEED     :: 2
SHIP_ATTACKSPEED  :: 300 //Lower is faster
SHIP_SIZE         :: 20
SHIP_LIVES        :: 3
SHIP_ACCELERATION :: 0.02
SHIP_DECELERATION :: 0.05
SHIP_TURNRATE     :: 0.01
SHIP_MAXBULLET    :: 100
SHIP_BULLETSPEED  :: 1
SHIP_BULLETSIZE   :: 7
SHIP_INVULNTIME   :: 2000

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
  bullets:        [dynamic]^Bullet
  attack_speed:   u32
  shot_time:      u32 
  invuln_time:    u32 
  invuln_length:  u32 
}

Bullet :: struct {
  position: Vector2d
  velocity: Vector2d
  size:     int 
}

init_ship :: proc(ship: ^Ship) {

  ship.size         = SHIP_SIZE
  ship.position     = Vector2d{500, 500}
  ship.lives        = SHIP_LIVES
  ship.attack_speed = SHIP_ATTACKSPEED
  ship.invuln_length = SHIP_INVULNTIME

  ship.bullets = make([dynamic]^Bullet)

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
    for i := 0; i < ship.lives; i += 1 {
      draw_rect(100 + (20 * i), 80, 10, 10, 0xFFFF3333, view)
    }
  }
}

update_ship :: proc(ship: ^Ship, controls: ^Controls, view: ^View) {

  thrust := get_direction(ship.local_vertices[0])
  thrust *= SHIP_ACCELERATION * f32(controls.accelerate)
  apply_force(&ship.velocity, &thrust)

  thrust = get_direction(ship.velocity) * -1
  thrust *= SHIP_DECELERATION* f32(controls.halt)
  apply_force(&ship.velocity, &thrust)

  rotate_ship(ship, SHIP_TURNRATE * f32(controls.turn))

  Vector2d_limit(&ship.velocity, SHIP_MAXSPEED)
  ship.position += ship.velocity

  bound_position(&ship.position, ship.hit_radius, view) 

  for i := 0; i < len(ship.world_vertices); i += 1 {
    ship.world_vertices[i] = ship.local_vertices[i] + ship.position
  }

  bulletCount := len(ship.bullets)
  for i := 0; i < bulletCount; i += 1 {
    ship.bullets[i].position = ship.bullets[i].position + ship.bullets[i].velocity
  }
  for i := 0; i < bulletCount; i += 1 {
    if ship.bullets[i].position[0] > f32(view.width) || ship.bullets[i].position[0] < 0 ||
       ship.bullets[i].position[1] > f32(view.height) || ship.bullets[i].position[1] < 0  {
      destroy_bullet(&ship.bullets, i)
      bulletCount -= 1
    }
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

shoot_bullet :: proc(ship: ^Ship, time: u32) {
  if time >= ship.shot_time + ship.attack_speed  {
    create_bullet(ship)
    ship.shot_time = time
  }
}

create_bullet :: proc(ship: ^Ship) {
  bullet := new(Bullet)

  direction := get_direction(ship.local_vertices[0])
  bullet.velocity = (direction) * SHIP_BULLETSPEED
  bullet.velocity += ship.velocity
  Vector2d_limit(&bullet.velocity, 2)

  bullet.position = ship.local_vertices[0] + ship.position
  bullet.size = SHIP_BULLETSIZE

  append(&ship.bullets, bullet)
}

destroy_bullet :: proc(bullets: ^[dynamic]^Bullet, index: int) {
  tmp := bullets[len(bullets) - 1]
  free(bullets[index])
  bullets[index] = tmp
  pop(bullets)
}

draw_bullets :: proc(bullets: ^[dynamic]^Bullet, color: u32, view: ^View) {
  for bullet in bullets {
    draw_bullet(bullet, color, view)
  }
}
draw_bullet :: proc(bullet: ^Bullet, color: u32, view: ^View) {
  half := bullet.size / 2
  draw_rect( -half + int(bullet.position[0]), -half + int(bullet.position[1]), 
             bullet.size, bullet.size,
             color, view)
}
