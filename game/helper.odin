package main

bound_position:: proc(position: ^Vector2d, hit_radius: f32, view: ^View) {
  if position[0] > f32(view.width) {
    position[0] = 0 - (hit_radius * 2 ) + 1
  } 
  else if position[0] < 0 - hit_radius * 2  {
    position[0] = f32(view.width) 
  }
  if position[1] > f32(view.height) {
    position[1] = 0 - (hit_radius * 2) + 1
  } 
  else if position[1] < 0 - (hit_radius * 2)  {
    position[1] = f32(view.height) 
  }
}

get_direction :: proc(vector: Vector2d) -> (direction: Vector2d) {
  direction = vector
  Vector2d_normalise(&direction)
  return
}

int_to_u8_array ::proc(a: int) -> (array: [4]u8) {
  array[0] = u8(a >> 24)
  array[1] = u8(a >> 16)
  array[2] = u8(a >> 8)
  array[3] = u8(a )
  return
}

u8_array_to_int :: proc(array: []u8) -> (num: int) {
  num += int(array[0]) << 24
  num += int(array[1]) << 16
  num += int(array[2]) << 8
  num += int(array[3]) 
  return
}
