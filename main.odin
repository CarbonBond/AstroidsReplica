package main 

// Imports
import "core:fmt"
import SDL "vendor:sdl2"

//Constants
WINDOW_FLAGS :: SDL.WINDOW_SHOWN + SDL.WINDOW_BORDERLESS
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
FPS          :: 60
TARGET_DT    :: 1000 / FPS

Game :: struct {
  perf_frequency: f64,
  renderer: ^SDL.Renderer,
  is_running: bool
}

game := Game{}

main :: proc() {

  assert(SDL.Init(SDL.INIT_EVERYTHING) == 0, SDL.GetErrorString())
  defer SDL.Quit()

  display_mode : SDL.DisplayMode
  assert(SDL.GetCurrentDisplayMode(0, &display_mode) == 0, SDL.GetErrorString())

  WINDOW_HEIGHT := display_mode.h
  WINDOW_WIDTH := display_mode.w 


  window := SDL.CreateWindow(
    "Odin Astroids",
    SDL.WINDOWPOS_CENTERED,
    SDL.WINDOWPOS_CENTERED,
    640,
    480
    WINDOW_FLAGS
  )
  assert(window != nil, SDL.GetErrorString())
  defer SDL.DestroyWindow(window)

  game.renderer = SDL.CreateRenderer( window, -1, RENDER_FLAGS)
  assert(render != nil, SDL.GetErrorString())
  defer SDL.DestroyRenderer(game.renderer)

  event : SDL.Event
  state : [^]u8

  game.is_running = true
  prevTime : u32 = 0;

  game_loop : for game.is_running {

    process_input(&event)
    update(&prevTime)
    render()

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
  defer prevTime^ = SDL.GetTicks()

}
render :: proc() {
}
