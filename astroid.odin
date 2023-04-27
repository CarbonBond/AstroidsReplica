package main

import rand "core:math/rand"
import "core:mem"

Astroid :: struct {
  size: int 
  width: int
  height: int
  vertices: [dynamic]Vertex
}

createAstroid :: proc() -> (astroid: ^Astroid) {
  astroid = cast(^Astroid)mem.alloc(size_of(astroid))
  astroid.size = int(rand.float32() * 6) 
  astroid.width = int(rand.float32() * 10) * astroid.size 
  astroid.height = int(rand.float32() * 10) * astroid.size
  astroid.vertices = {{0,0},{astroid.width, 0},{astroid.width, astroid.height}, {0, astroid.height}}

  return
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
