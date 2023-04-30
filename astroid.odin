package main

import rand "core:math/rand"
import "core:mem"
import "core:fmt"

Astroid :: struct {
  size: int 
  hit_radius: f32
  position: Vector2d
  velocity: Vector2d
  vertices: []Vector2d
  world_vertices: []Vector2d
}

ASTROID_SCALE :: 100

init_astroids :: proc(astroids: ^[dynamic]^Astroid, amount: int, view: View) {
  for i := 0; i < amount; i += 1 {
    append(astroids, createAstroid(view))
  }
}

createAstroid :: proc(view : View, size := 3) ->  ^Astroid {
  astroid := cast(^Astroid)mem.alloc(size_of(Astroid))

  {
    sign_x := int(rand.int31()) % 100
    sign_y := int(rand.int31()) % 100

    //Random location
    px := rand.float32() * f32(view.width)
    py := rand.float32() * f32(view.height)

    //Random Velocity
    vx := f32(int(rand.int31()) % 500) / 200;
    vy := f32(int(rand.int31()) % 500) / 200;

    if sign_x >= 50 {
      vx = -vx
    }
    if sign_y >= 50 {
      vy = -vy
    }
    
    astroid.position[0] = f32(px)
    astroid.position[1] = f32(py)
    astroid.velocity[0] = f32(vx)
    astroid.velocity[1] = f32(vy)
  }
  
  astroid.size = int(size) 
  astroid.vertices = make([]Vector2d, 8)
  astroid.world_vertices = make([]Vector2d, 8)
  astroid.hit_radius = ASTROID_SCALE / 2

  // Creates random looking astroid
  {
    //Top left
    astroid.vertices[0] = {rand.float32()* 0.25 ,
                         rand.float32() * 0.25}
    //Top middle
    astroid.vertices[1] = {rand.float32() * 0.25 + 0.25,
                         rand.float32() * 0.25}
    //Top right
    astroid.vertices[2] = {rand.float32() * 0.25 + 0.75 ,
                         rand.float32() * 0.25}
    //Right middle
    astroid.vertices[3] = {rand.float32() * 0.25 + 0.75,
                         rand.float32() * 0.25 + 0.25}
    //Bottom right
    astroid.vertices[4] = {rand.float32() * 0.25 + 0.75,
                         rand.float32() * 0.25 + 0.75}
    //Bottom middle
    astroid.vertices[5] = {rand.float32() * 0.25 + 0.25,
                         rand.float32() * 0.25 + 0.75}
    //Bottom left
    astroid.vertices[6] = {rand.float32() * 0.25,
                         rand.float32() * 0.25 + 0.75}
    //Middle left
    astroid.vertices[7] = {rand.float32() * 0.25,
                         rand.float32() * 0.25 + 0.25}

    screenTranslation := Vector2d{f32(view.width/2), f32(view.height/2)}
    for i := 0; i < len(astroid.vertices); i += 1 {
      astroid.vertices[i] = astroid.vertices[i] * ASTROID_SCALE
      astroid.world_vertices[i] += astroid.vertices[i] + screenTranslation
    }

  }

  return astroid
}

destroy_astroids :: proc(astroids: ^[dynamic]^Astroid) {
  for astroid in astroids {
    destroyAstroid(astroid)
  } 
}

destroyAstroid :: proc(astroid: ^Astroid){
  delete(astroid.vertices)
  free(astroid)
}

update_astroids :: proc(astroids: ^[dynamic]^Astroid, view: View) {
  for astroid in astroids {
    fmt.println(astroid)
    updateAstroid(astroid, view)
  } 
}
updateAstroid :: proc(astroid: ^Astroid, view: View) {
  screenTranslation := Vector2d{f32(view.width/2), f32(view.height/2)}
  astroid.position += astroid.velocity 
  for i := 0; i < len(astroid.vertices); i += 1 {
    astroid.world_vertices[i] = astroid.vertices[i] + astroid.position + screenTranslation
  }
}

draw_astroids :: proc(astroids: ^[dynamic]^Astroid, color : u32, view: View) {
  for astroid in astroids {
    draw_astroid(astroid, color, view)
  } 
}

draw_astroid :: proc(astroid: ^Astroid, color: u32, view: View) {
  x1, x2, y1, y2 : int
  for i := 0; i < len(astroid.world_vertices)-1; i += 1 {
    x1 = int(astroid.world_vertices[i][0]   + astroid.position[0])
    y1 = int(astroid.world_vertices[i][1]   + astroid.position[1])
    x2 = int(astroid.world_vertices[i+1][0] + astroid.position[0])
    y2 = int(astroid.world_vertices[i+1][1] + astroid.position[1])
    draw_line(x1, y1, x2, y2, color, view)
  }
  x1 = int(astroid.world_vertices[0][0]   + astroid.position[0])
  y1 = int(astroid.world_vertices[0][1]   + astroid.position[1])
  x2 = int(astroid.world_vertices[len(astroid.vertices)-1][0] + astroid.position[0])
  y2 = int(astroid.world_vertices[len(astroid.vertices)-1][1] + astroid.position[1])
  draw_line(x1, y1, x2, y2, color, view)
}
