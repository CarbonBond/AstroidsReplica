package main

import "core:math"
import "core:fmt"

Vector2d :: [2]f32
Vector3d :: [3]f32

Vector2d_add_new :: proc(a, b: ^Vector2d) -> (result: ^Vector2d) {
  result = new(Vector2d)
  result^ = a^ + b^ 
  return result
}

Vector2d_rotate :: proc(vector: ^Vector2d, turn: f32) {
  angle :=  math.PI * 2 * turn
  sin   := math.sin_f32(angle)
  cos   := math.cos_f32(angle)

  m := matrix[2, 2]f32{cos, -sin, 
                       sin,  cos}

  vector^ = Vector2d((vector^) * m)
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

Vector3d_normalise :: proc(vector: ^Vector3d) {
  length := Vector3d_length(vector)
  result := vector^ * length
  return
}

Vector3d_length :: proc(vector: ^Vector3d) -> (result: f32) {
  tmp := vector^ * vector^
  vector := math.sqrt_f32(tmp[0] + tmp[1] + tmp[2])
  return
}

Vector3d_dot :: proc(a, b: ^Vector3d) -> (result: f32) {
  tmp := a^ * b^
  result = tmp[0] + tmp[1] + tmp[2]
  return
}

Vector3d_cross :: proc(a, b: ^Vector3d) -> (result: Vector3d) {
  result[0] = ((a[1] * b[2]) - (a[2] * b[1]))
  result[1] = ((a[0] * b[2]) - (a[2] * b[0]))
  result[2] = ((a[1] * b[0]) - (a[0] * b[1]))
  return
}

Vector3d_rotate_x :: proc(vector: Vector3d, turn: f32) -> (result: Vector3d) {
  angle :=  math.PI * 2 * turn
  sin   := math.sin_f32(angle)
  cos   := math.cos_f32(angle)

  m := matrix[2, 2]f32{cos, -sin, 
                       sin,  cos}

 temp := Vector2d((Vector2d{vector[1], vector[2]}) * m)

  result[0] = vector[0]
  result[1] = temp[0]
  result[2] = temp[1]
  return
}
Vector3d_rotate_y :: proc(vector: Vector3d, turn: f32) -> (result: Vector3d) {
  angle :=  math.PI * 2 * turn
  sin   := math.sin_f32(angle)
  cos   := math.cos_f32(angle)

  m := matrix[2, 2]f32{cos, -sin, 
                       sin,  cos}

  temp := Vector2d((Vector2d{vector[0], vector[2]}) * m)

  result[0] = temp[0]
  result[1] = vector[1]
  result[2] = temp[1]
  return
}
Vector3d_rotate_z :: proc(vector: Vector3d, turn: f32) -> (result: Vector3d) {
  angle :=  math.PI * 2 * turn
  sin   := math.sin_f32(angle)
  cos   := math.cos_f32(angle)

  m := matrix[2, 2]f32{cos, -sin, 
                       sin,  cos}

  temp := Vector2d((Vector2d{vector[0], vector[1]}) * m)

  result[0] = temp[0]
  result[1] = temp[1]
  result[2] = vector[2]
  return
}
