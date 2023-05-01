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

RENDER_WRAP  :: true

NEON_GREEN   :: 0xFFAAFFAA
NEON_RED     :: 0xFFFFAAAA

ASTROID_COUNT :: 4
SHIP_ACCELERATION :: 0.06


Game :: struct {
  perf_frequency: f64,
  renderer: ^SDL.Renderer,
  view: View,
  is_running: bool,
  astroids: [dynamic]^Astroid
}

Keypress :: [5]int
Controls :: enum{
  accelerate
  decelerate
  tLeft
  tRight
  shoot
}

ship : Ship

game := Game{}
keys := Keypress{}

main :: proc() {
  //rand.set_global_seed(0xFFFFFFFF)

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
  prevTime : u32 = SDL.GetTicks();

  setup()
  defer free(game.view.color_buffer)
  defer destroy_astroids(&game.astroids)

  game_loop : for game.is_running {

    process_input(&event)
    update(&prevTime)
    render()

  }
}

setup :: proc() {
  game.view.color_buffer = cast(^u32)mem.alloc(size_of(u32) * game.view.width * game.view.height)
  assert(game.view.color_buffer != nil, "Error: Couldn't allocate color_buffer")

  init_astroids(&game.astroids, ASTROID_COUNT, &game.view)
  init_ship(&ship)

  game.view.color_buffer_texture = SDL.CreateTexture(
    game.renderer,
    372645892,
    SDL.TextureAccess.STREAMING,
    cast(i32)game.view.width,
    cast(i32)game.view.height
  )

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
        case .W:
          fallthrough
        case .UP:
          thrust := get_direction(ship.local_vertices[0])
          thrust *= SHIP_ACCELERATION
          apply_force(&ship.velocity, &thrust)

        case .A:
          fallthrough
        case .LEFT:
          rotate_ship(&ship, 0.01)

        case .D:
          fallthrough
        case .RIGHT:
          rotate_ship(&ship, -0.01)

      }
  }

  kb := SDL.GetKeyboardState(nil);
  keys[Controls.accelerate] = int(kb[SDL.Scancode.W])
  keys[Controls.decelerate] = int(kb[SDL.Scancode.S])
}

update :: proc(prevTime: ^u32){
  waitTime := TARGET_DT - (SDL.GetTicks() - prevTime^);
  prevTime := prevTime
  if(waitTime > 0 && waitTime <= TARGET_DT) do SDL.Delay(waitTime)
  prevTime^ = SDL.GetTicks()

  update_astroids(&game.astroids, &game.view)
  update_ship(&ship, &game.view)

  /*
  ship.acceleration += ((ship.acceleration * ship.acceleration) + (2 * ship.acceleration) ) 
  ship.speed = 10
  ship.position[1] -= f32((ship.speed + ship.acceleration) * keys[Controls.accelerate])
  ship.position[1] += f32(ship.speed * keys[Controls.decelerate])
  */
}

render :: proc() {

  draw_ship(&ship, NEON_GREEN, &game.view)
  draw_astroids(&game.astroids, NEON_RED, &game.view)
  render_color_buffer(game.renderer, &game.view)
  clear_color_buffer(0xFF121212, &game.view)

  SDL.RenderPresent(game.renderer)
}


