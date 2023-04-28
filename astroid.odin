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

createAstroid :: proc() -> (astroid: ^Astroid) {
  astroid = cast(^Astroid)mem.alloc(size_of(astroid))
  astroid.size = int(rand.float32() * 6) 
  astroid.width = int(rand.float32() * 100) * astroid.size 
  astroid.height = int(rand.float32() * 100) * astroid.size
  vertices := make([]Vertex, 6)
  
  OneThirdWidth := f32(astroid.width) * 0.3  
  OneHalfHeight := f32(astroid.height) * 0.5  

  vertices[0] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3),
                       int(rand.float32() * f32(astroid.height) * 0.5)}
  vertices[1] = Vertex{int(rand.float32() * f32(astroid.width) * 0.6 + OneThirdWidth),
                       int(rand.float32() * f32(astroid.height) * 0.5)}
  vertices[2] = Vertex{int(rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2)) ,
                       int(rand.float32() * f32(astroid.height) * 0.5)}
  vertices[3] = Vertex{int(rand.float32() * f32(astroid.width)  * 0.3 + (OneThirdWidth * 2)) ,
                       int(rand.float32() * f32(astroid.height) * 0.5 + OneHalfHeight)}
  vertices[4] = Vertex{int(rand.float32() * f32(astroid.width) * 0.6 + OneThirdWidth),
                       int(rand.float32() * f32(astroid.height) * 0.5 + OneHalfHeight)}
  vertices[5] = Vertex{int(rand.float32() * f32(astroid.width) * 0.3),
                       int(rand.float32() * f32(astroid.height) * 0.5 + OneHalfHeight)}

  astroid.vertices = vertices

  fmt.println(astroid.vertices)

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
