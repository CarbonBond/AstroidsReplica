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
NEON_YELLOW  :: 0xFFFFFFAA

ADDRESS :: "127.0.0.1"
PORT :: 7777

ASTROID_COUNT :: 4

temp : [10]u8


Game :: struct {
  perf_frequency: f64,
  renderer: ^SDL.Renderer,
  view: View,
  is_running: bool,
  astroids: [dynamic]^Astroid
  connection: ^Connection
}

Keypress :: [5]int
Controls :: struct {
  accelerate : int
  halt       : int
  turn       : int
  shoot      : int
}

ship : Ship
controls : Controls

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
  defer close_connection(game.connection)

  game_loop : for game.is_running {

    process_input(&event)
    update(&prevTime)
    when SERVER {}
    else {
        render()
    }

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

  game.connection = create_connection(PORT, ADDRESS)
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
         controls.accelerate = 1

        case .A:
          fallthrough
        case .LEFT:
          controls.turn = 1

        case .D:
          fallthrough
        case .RIGHT:
          controls.turn = -1

        case .S:
          fallthrough
        case .DOWN:
          controls.halt = 1

        case .SPACE:
          controls.shoot = 1

        case .R:
          ship.lives += 1
      }
    case SDL.EventType.KEYUP:
      #partial switch event.key.keysym.scancode {

        case .W:
          fallthrough
        case .UP:
         controls.accelerate = 0

        case .A:
          fallthrough
        case .LEFT:
          fallthrough
        case .D:
          fallthrough
        case .RIGHT:
          controls.turn = 0

        case .S:
          fallthrough
        case .DOWN:
          controls.halt = 0

        case .SPACE:
          controls.shoot = 0
      }
  }
}

update :: proc(prevTime: ^u32){
  curTime  := SDL.GetTicks()
  waitTime := TARGET_DT - (curTime - prevTime^);
  if(waitTime > 0 && waitTime <= TARGET_DT) do SDL.Delay(waitTime)
  prevTime^ = SDL.GetTicks()

  update_astroids(&game.astroids, &ship, curTime, &game.view)
  update_ship(&ship, &controls, &game.view)

  if controls.shoot == 1 {
    shoot_bullet(&ship, curTime)
  }
  when SERVER{

    recieve_data(game.connection, temp[:]) 
    fmt.println(temp)
  } else {
    send_data(game.connection, []u8{1,2,3,4})
  }
}

render :: proc() {

  draw_ship(&ship, NEON_GREEN, &game.view)
  draw_bullets(&ship.bullets, NEON_YELLOW, &game.view)
  draw_astroids(&game.astroids, NEON_RED, &game.view)
  render_color_buffer(game.renderer, &game.view)
  clear_color_buffer(0xFF121212, &game.view)

  SDL.RenderPresent(game.renderer)
}

