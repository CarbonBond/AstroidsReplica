package main 
import "core:math"
import "core:mem"
import SDL "vendor:sdl2"


View :: struct {
  window: ^SDL.Window,
  height: int,
  width: int
  color_buffer: ^u32, 
  color_buffer_texture: ^SDL.Texture,
}

draw_pixel :: proc(x: int, y: int, color: u32, view: ^View) {
  if y >= 0 && y < view.height && x >= 0 && x < view.width {
    location := mem.ptr_offset(view.color_buffer,(y*view.width) + x)
    location^ = color;
  }
}

draw_line :: proc(x0, y0, x1, y1: int, color: u32, view: ^View) {
  delta_x := (x1-x0)
  delta_y := (y1-y0)

  side_length : int 
  if ( math.abs(delta_x) >= math.abs(delta_y) ) {
    side_length = math.abs(delta_x) 
  }
  else {
    side_length = math.abs(delta_y)
  }

  x_inc := f32(delta_x) / f32(side_length)
  y_inc := f32(delta_y) / f32(side_length)

  current_x := f32(x0)
  current_y := f32(y0)

  for i := 0; i <= side_length; i += 1 {
    draw_pixel(int(math.round(current_x)), int(math.round(current_y)), color, view)
    current_x += x_inc
    current_y += y_inc
  }
}

draw_rect :: proc(x, y, width, height: int, color: u32, view: ^View) {
  for current_y := y; current_y < y + height; current_y += 1 {
    for current_x := x; current_x < x + width; current_x += 1 {
      draw_pixel(current_x, current_y, color, view)
    }
  }
}

clear_color_buffer :: proc(color: u32, view: ^View) {
  for current_y := 0; current_y < view.height; current_y += 1 {
    for current_x := 0; current_x < view.width; current_x += 1 {
      draw_pixel(current_x, current_y, color, view)
    }
  }
}

render_color_buffer :: proc(renderer: ^SDL.Renderer, view: ^View) {
  SDL.UpdateTexture(
      view.color_buffer_texture,
      nil,
      view.color_buffer,
      i32(view.width*size_of(u32))
      );
  SDL.RenderCopy(
      renderer,
      view.color_buffer_texture, 
      nil, nil);
}

