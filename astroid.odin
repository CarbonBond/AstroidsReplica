package main

import rand "core:math/rand"
import "core:mem"
import "core:fmt"

Astroid :: struct {
  size: int 
  width: int
  height: int
  position: Vertex
  vertices: []Vertex
}

createAstroid :: proc(width := 100, height := 100, size:= 3) ->  ^Astroid {
  astroid := cast(^Astroid)mem.alloc(size_of(Astroid))
  astroid.size = int(size) 
  astroid.width = int(f32(height)) * astroid.size 
  astroid.height = int( f32(height)) * astroid.size
  astroid.vertices = make([]Vertex, 8)
  
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
  for i := 0; i < len(astroid.vertices)-1; i += 1 {
    draw_line(cast(int)astroid.vertices[i][0],cast(int)astroid.vertices[i][1], 
              cast(int)astroid.vertices[i + 1][0],cast(int) astroid.vertices[i + 1][1],
              color, view)
  }
  draw_line(cast(int)astroid.vertices[0][0],cast(int)astroid.vertices[0][1], 
            cast(int)astroid.vertices[len(astroid.vertices)-1][0], cast(int)astroid.vertices[len(astroid.vertices)-1][1],
            color, view)
}
