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

