package main 

// Imports
import "core:fmt"
import "core:mem"
import SDL "vendor:sdl2"
import rand "core:math/rand"

//Constants
WINDOW_FLAGS :: SDL.WINDOW_SHOWN + SDL.WINDOW_BORDERLESS
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
FPS          :: 60
TARGET_DT    :: 1000 / FPS

NEON_GREEN   :: 0xFFAAFFAA


Game :: struct {
  perf_frequency: f64,
  renderer: ^SDL.Renderer,
  view: View,
  is_running: bool,
}

Vertex :: [2]f32

game := Game{}




main :: proc() {
  //rand.set_global_seed(0xFFFFFFFF)
  astroid := createAstroid()
  defer destroyAstroid(astroid)

  assert(SDL.Init(SDL.INIT_EVERYTHING) == 0, SDL.GetErrorString())
  defer SDL.Quit()

  display_mode : SDL.DisplayMode
  assert(SDL.GetCurrentDisplayMode(0, &display_mode) == 0, SDL.GetErrorString())

  game.view.height = int(display_mode.h)
  game.view.width  = int(display_mode.w)


  game.view.window = SDL.CreateWindow(
    "Odin Astroids",
    SDL.WINDOWPOS_CENTERED,
    SDL.WINDOWPOS_CENTERED,
    cast(i32)game.view.width,
    cast(i32)game.view.height,
    WINDOW_FLAGS
  )
  assert(game.view.window != nil, SDL.GetErrorString()) 
  defer SDL.DestroyWindow(game.view.window)

  game.renderer = SDL.CreateRenderer( game.view.window, -1, RENDER_FLAGS)
  assert(render != nil, SDL.GetErrorString())
  defer SDL.DestroyRenderer(game.renderer)

  event : SDL.Event
  state : [^]u8

  game.is_running = true
  prevTime : u32 = 0;

  setup()
  defer free(game.view.color_buffer)

  game_loop : for game.is_running {

    process_input(&event)
    update(&prevTime)
    render(astroid)

  }
}

process_input :: proc(event: ^SDL.Event) {

  SDL.PollEvent(event)
  #partial switch  event.type {

    case SDL.EventType.QUIT:
      game.is_running = false

    case SDL.EventType.KEYDOWN:
      #partial switch event.key.keysym.scancode {
        case .ESCAPE:
          game.is_running = false
        }
      
  }
}
update :: proc(prevTime: ^u32){
  waitTime := TARGET_DT - (SDL.GetTicks() - prevTime^);
  prevTime := prevTime
  if(waitTime > 0 && waitTime <= TARGET_DT) do SDL.Delay(waitTime)
  prevTime^ = SDL.GetTicks()

}
render :: proc(astroid: ^Astroid) {

  astroid.position = {astroid.position[0] + 10, astroid.position[1] + 10} 
  draw_astroid(astroid, NEON_GREEN, game.view)
  render_color_buffer(game.view, game.renderer)
  clear_color_buffer(0xFF121212, game.view)

  SDL.RenderPresent(game.renderer)
}


setup :: proc() {
  game.view.color_buffer = cast(^u32)mem.alloc(size_of(u32) * game.view.width * game.view.height)
  assert(game.view.color_buffer != nil, "Error: Couldn't allocate color_buffer")

  game.view.color_buffer_texture = SDL.CreateTexture(
    game.renderer,
    372645892,
    SDL.TextureAccess.STREAMING,
    cast(i32)game.view.width,
    cast(i32)game.view.height
  )

}



