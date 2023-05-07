package main 

// Imports
import "core:fmt"
import "core:mem"
import NET "core:net"
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

temp : [100]u8


Game :: struct {
  perf_frequency: f64,
  display_mode: SDL.DisplayMode
  renderer: ^SDL.Renderer,
  view: View,
  is_running: bool,
  not_started: bool,
  astroids: [dynamic]^Astroid
  connection: ^Connection
  connections: map[string]Receiver
}

Controls_enum :: enum u8 {
  accelerate = 0 
  halt       = 1
  lTurn      = 2
  rTurn      = 3
  shoot      = 4
  exit       = 5
}

ships : [dynamic]^Ship

game := Game{}

main :: proc() {
  rand.set_global_seed(0xFFFFFFFF)

  setup()
  defer close()

  event : SDL.Event
  prevTime : u32 = SDL.GetTicks();

  game_loop : for game.is_running {

    update(&prevTime)
    when SERVER {}
    else {
        process_input(&event)
        render()
    }

  }
}

setup :: proc() {

  assert(SDL.Init(SDL.INIT_EVERYTHING) == 0, SDL.GetErrorString())
  assert(SDL.GetCurrentDisplayMode(0, &game.display_mode) == 0, SDL.GetErrorString())

  game.view.height = int(game.display_mode.h)
  game.view.width  = int(game.display_mode.w)

  game.not_started = true

  game.connection = create_connection(PORT, ADDRESS)
  game.connections = make(map[string]Receiver)

  when SERVER {
  }
  else {

    game.view.window = SDL.CreateWindow(
      "Odin Astroids",
      SDL.WINDOWPOS_CENTERED,
      SDL.WINDOWPOS_CENTERED,
      cast(i32)game.view.width,
      cast(i32)game.view.height,
      WINDOW_FLAGS
    )
    assert(game.view.window != nil, SDL.GetErrorString()) 

    game.renderer = SDL.CreateRenderer( game.view.window, -1, RENDER_FLAGS)
    assert(render != nil, SDL.GetErrorString())

    game.view.color_buffer = cast(^u32)mem.alloc(size_of(u32) * game.view.width * game.view.height)
    assert(game.view.color_buffer != nil, "Error: Couldn't allocate color_buffer")

    game.view.color_buffer_texture = SDL.CreateTexture(
      game.renderer,
      372645892,
      SDL.TextureAccess.STREAMING,
      cast(i32)game.view.width,
      cast(i32)game.view.height
    )
    append(&ships, create_ship(&game.view))
    init_ship(ships[0])
  }


  game.is_running = true

  
  init_astroids(&game.astroids, ASTROID_COUNT, &game.view)

}

close :: proc() {
  when SERVER {
  } else {
    defer SDL.Quit()
    defer SDL.DestroyWindow(game.view.window)
    defer SDL.DestroyRenderer(game.renderer)
    defer free(game.view.color_buffer)
  }
  defer destroy_astroids(&game.astroids)
  defer close_connection(game.connection)
}

process_input :: proc(event: ^SDL.Event) {

  SDL.PollEvent(event)
  #partial switch  event.type {

    case SDL.EventType.QUIT:
      game.is_running = false

    case SDL.EventType.KEYDOWN:
      #partial switch event.key.keysym.scancode {
        case .ESCAPE:
           incl(&ships[0].controls, Controls_enum.exit)

        case .W:
          fallthrough
        case .UP:
         incl(&ships[0].controls, Controls_enum.accelerate)

        case .A:
          fallthrough
        case .LEFT:
          incl(&ships[0].controls, Controls_enum.lTurn)

        case .D:
          fallthrough
        case .RIGHT:
          incl(&ships[0].controls, Controls_enum.rTurn)

        case .S:
          fallthrough
        case .DOWN:
          incl(&ships[0].controls, Controls_enum.halt)

        case .SPACE:
          incl(&ships[0].controls, Controls_enum.shoot)

        case .R:
          ships[0].lives += 1
      }
    case SDL.EventType.KEYUP:
      #partial switch event.key.keysym.scancode {

        case .W:
          fallthrough
        case .UP:
          excl(&ships[0].controls, Controls_enum.accelerate)

        case .A:
          fallthrough
        case .LEFT:
          excl(&ships[0].controls, Controls_enum.lTurn)

        case .D:
          fallthrough
        case .RIGHT:
          excl(&ships[0].controls, Controls_enum.rTurn)

        case .S:
          fallthrough
        case .DOWN:
          excl(&ships[0].controls, Controls_enum.halt)

        case .SPACE:
          excl(&ships[0].controls, Controls_enum.shoot)
      }
  }
}

update :: proc(prevTime: ^u32){
  curTime  := SDL.GetTicks()
  waitTime := TARGET_DT - (curTime - prevTime^);
  if(waitTime > 0 && waitTime <= TARGET_DT) do SDL.Delay(waitTime)
  prevTime^ = SDL.GetTicks()



  
  when SERVER{
    received := receive_data(game.connection, temp[:], len(game.connections) 
    if received.name in game.connections {
      for key, value in game.connections {
        data := []u8{transmute(u8)ships[value.id].controls} 
        send
      }
    }
    else {
      game.connections[receiver.name] = receiver
    }
  } else {

    //Send your ships controls to server
    data := []u8{transmute(u8)ships[0].controls} 
    send_data(game.connection, data)

    received := receive_data(game.connection, temp[:]) 
    if received.name in game.connections {
      for key, value in game.connections {
        ships[value].controls = transmute(Controls)(temp[0])
      }
  }
    for ship in ships {
      update_astroids(&game.astroids, ship, curTime, &game.view)
      update_ship(ship, &game.view)
      if Controls_enum.shoot in ship.controls do shoot_bullet(ship, curTime)
      if Controls_enum.exit  in ship.controls do game.is_running = false
    }
  }

render :: proc() {

  draw_ship(ships[0], NEON_GREEN, &game.view)
  draw_bullets(&ships[0].bullets, NEON_YELLOW, &game.view)
  draw_astroids(&game.astroids, NEON_RED, &game.view)
  render_color_buffer(game.renderer, &game.view)
  clear_color_buffer(0xFF121212, &game.view)

  SDL.RenderPresent(game.renderer)
}

