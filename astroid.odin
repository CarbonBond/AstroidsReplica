package main

import rand "core:math/rand"
import "core:mem"
import "core:fmt"

Astroid :: struct {
  size: int 
  width: int
  height: int
  vertices: []Vertex
}

createAstroid :: proc(width := 100, height := 100, size:= 5) -> (astroid: ^Astroid ) {
  astroid = cast(^Astroid)mem.alloc(size_of(astroid))
  astroid.size = int(size) 
  astroid.width = int(rand.float32() * f32(height)) * astroid.size 
  astroid.height = int(rand.float32() * f32(height)) * astroid.size
  vertices := make([]Vertex, 8)
  
  OneThirdWidth := f32(astroid.width) * 0.3  
  OneThirdHeight := f32(astroid.height) * 0.5  

  //Top left
  vertices[0] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3),
                       int(rand.float32() * f32(astroid.height) * 0.3)}
  //Top middle
  vertices[1] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3 + OneThirdWidth),
                       int(rand.float32() * f32(astroid.height) * 0.3)}
  //Top right
  vertices[2] = Vertex{int(rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2)) ,
                       int(rand.float32() * f32(astroid.height) * 0.3)}
  //Right middle
  vertices[3] = Vertex{int(rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2)) ,
                       int(rand.float32() * f32(astroid.height) * 0.3 + OneThirdHeight)}
  //Bottom right
  vertices[4] = Vertex{int(rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2)) ,
                       int(rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2))}
  //Bottom middle
  vertices[5] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3 + OneThirdWidth),
                       int(rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2))}
  //Bottom left
  vertices[6] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3),
                       int(rand.float32() * f32(astroid.height) * 0.3 + (OneThirdHeight * 2))}
  //Middle left
  vertices[7] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3),
                       int(rand.float32() * f32(astroid.height) * 0.3 + OneThirdHeight)}

  astroid.vertices = vertices

  fmt.println(astroid)

  return
}

destroyAstroid :: proc(astroid: ^Astroid){
  delete(astroid.vertices)
  free(astroid)
}

draw_astroid :: proc(astroid: ^Astroid, color: u32, view: View) {
  for i := 0; i < len(astroid.vertices)-1; i += 1 {
    draw_line(astroid.vertices[i].x,astroid.vertices[i].y, 
              astroid.vertices[i + 1].x, astroid.vertices[i + 1].y,
              color, view)
  }
  draw_line(astroid.vertices[0].x,astroid.vertices[0].y, 
            astroid.vertices[len(astroid.vertices)-1].x, astroid.vertices[len(astroid.vertices)-1].y,
            color, view)
}
