package main

import "core:math"
import "core:fmt"

Vector2d :: [2]f32

Vector2d_add_new :: proc(a, b: ^Vector2d) -> (result: ^Vector2d) {
  result = new(Vector2d)
  result^ = a^ + b^ 
  return result
}

Vector2d_rotate :: proc(vector: ^Vector2d, turn: f32) {
  angle :=  math.PI * 2 * turn
  sin   := math.sin_f32(angle)
  cos   := math.cos_f32(angle)

  fmt.println(vector)
  m := matrix[2, 2]f32{cos, -sin, 
                       sin,  cos}
  vector^ = Vector2d((vector^) * m)
  fmt.println(vector)
  return
}

Vector2d_dot :: proc(a, b: ^Vector2d) -> (result: f32) {
  tmp := a^ * b^ 
  result = (tmp[0] + tmp[1])
  return
}

Vector2d_length :: proc(vector: ^Vector2d) -> (result: f32) {
  tmp := vector^ * vector^
  result = math.sqrt_f32(tmp[0] + tmp[1])
  return 
}

Vector2d_normalise :: proc(vector: ^Vector2d){
  length := Vector2d_length(vector)
  vector := vector^ / length
}

Vector2d_limit :: proc(vector: ^Vector2d, limit: f32){
  length := Vector2d_length(vector)

  if length > limit {
    ratio := limit / length
    vector := vector^ * ratio
  }
}
