package main

import rand "core:math/rand"
import "core:mem"
import "core:fmt"

Astroid :: struct {
  size: int 
  width: int
  height: int
  position: Vector2d
  vertices: []Vector2d
  velocity: []Vector2d
}

createAstroid :: proc(width := 100, height := 100, size:= 3) ->  ^Astroid {
  astroid := cast(^Astroid)mem.alloc(size_of(Astroid))
  astroid.size = int(size) 
  astroid.width = int(f32(height)) * astroid.size 
  astroid.height = int( f32(height)) * astroid.size
  astroid.vertices = make([]Vector2d, 8)
  
  OneThirdWidth := f32(astroid.width) * 0.3  
  OneThirdHeight := f32(astroid.height) * 0.5  

  //Top left
  astroid.vertices[0] = {rand.float32() * f32(astroid.width) * 0.3 ,
                       rand.float32() * f32(astroid.height) * 0.3}
  //Top middle
  astroid.vertices[1] = {rand.float32() * f32(astroid.width) * 0.3 + OneThirdWidth,
                       rand.float32() * f32(astroid.height) * 0.3}
  //Top right
  astroid.vertices[2] = {rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2) ,
                       rand.float32() * f32(astroid.height) * 0.3}
  //Right middle
  astroid.vertices[3] = {rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2) ,
                       rand.float32() * f32(astroid.height) * 0.3 + OneThirdHeight}
  //Bottom right
  astroid.vertices[4] = {rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2) ,
                       rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2)}
  //Bottom middle
  astroid.vertices[5] = {rand.float32() * f32(astroid.width) * 0.3 + OneThirdWidth,
                       rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2)}
  //Bottom left
  astroid.vertices[6] = {rand.float32() * f32(astroid.width) * 0.3,
                       rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2)}
  //Middle left
  astroid.vertices[7] = {rand.float32() * f32(astroid.width) * 0.3,
                       rand.float32() * f32(astroid.height) * 0.3 + OneThirdHeight}

  fmt.println(astroid.vertices)
  return astroid
}

destroyAstroid :: proc(astroid: ^Astroid){
  delete(astroid.vertices)
  free(astroid)
}

draw_astroid :: proc(astroid: ^Astroid, color: u32, view: View) {
  x1, x2, y1, y2 : int
  for i := 0; i < len(astroid.vertices)-1; i += 1 {
    x1 = int(astroid.vertices[i][0]   + astroid.position[0]) - astroid.width/2 
    y1 = int(astroid.vertices[i][1]   + astroid.position[1]) - astroid.height/2
    x2 = int(astroid.vertices[i+1][0] + astroid.position[0]) - astroid.width/2
    y2 = int(astroid.vertices[i+1][1] + astroid.position[1]) - astroid.height/2
    draw_line(x1, y1, x2, y2, color, view)
  }
  x1 = int(astroid.vertices[0][0]   + astroid.position[0])  - astroid.width/2
  y1 = int(astroid.vertices[0][1]   + astroid.position[1]) - astroid.height/2
  x2 = int(astroid.vertices[len(astroid.vertices)-1][0] + astroid.position[0]) - astroid.width/2
  y2 = int(astroid.vertices[len(astroid.vertices)-1][1] + astroid.position[1]) - astroid.height/2
  draw_line(x1, y1, x2, y2, color, view)
}
