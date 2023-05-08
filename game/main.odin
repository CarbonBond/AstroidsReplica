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

ship_index : u8

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
    ship_index = 0
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

    send_data(game.connection, []u8{0xFF})
    ship_id : [2]u8
    received := receive_data(game.connection, ship_id[:]) 

    for i : u8 = 0; i < (ship_id[0]); i += 1 {
      append(&ships, create_ship())
      init_ship(ships[i])
    }
    append(&ships, create_ship())
      fmt.print("created ship")
    init_ship(ships[ship_id[0]])
    ship_index = ship_id[0]
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
           incl(&ships[ship_index].controls, Controls_enum.exit)

        case .W:
          fallthrough
        case .UP:
         incl(&ships[ship_index].controls, Controls_enum.accelerate)

        case .A:
          fallthrough
        case .LEFT:
          incl(&ships[ship_index].controls, Controls_enum.lTurn)

        case .D:
          fallthrough
        case .RIGHT:
          incl(&ships[ship_index].controls, Controls_enum.rTurn)

        case .S:
          fallthrough
        case .DOWN:
          incl(&ships[ship_index].controls, Controls_enum.halt)

        case .SPACE:
          incl(&ships[ship_index].controls, Controls_enum.shoot)

        case .R:
          ships[ship_index].lives += 1
      }
    case SDL.EventType.KEYUP:
      #partial switch event.key.keysym.scancode {

        case .W:
          fallthrough
        case .UP:
          excl(&ships[ship_index].controls, Controls_enum.accelerate)

        case .A:
          fallthrough
        case .LEFT:
          excl(&ships[ship_index].controls, Controls_enum.lTurn)

        case .D:
          fallthrough
        case .RIGHT:
          excl(&ships[ship_index].controls, Controls_enum.rTurn)

        case .S:
          fallthrough
        case .DOWN:
          excl(&ships[ship_index].controls, Controls_enum.halt)

        case .SPACE:
          excl(&ships[ship_index].controls, Controls_enum.shoot)
      }
  }
}

update :: proc(prevTime: ^u32){
  curTime  := SDL.GetTicks()
  waitTime := TARGET_DT - (curTime - prevTime^);
  if(waitTime > 0 && waitTime <= TARGET_DT) do SDL.Delay(waitTime)
  prevTime^ = SDL.GetTicks()

  when SERVER {
    rec_data : [2]u8
    received := receive_data(game.connection, rec_data[:] )
    if received.name in game.connections {
      for key, value in game.connections {
        connection := value.connection
        if (rec_data[1] & 0b100000) == 0b100000 do game.is_running = false
        send_data(&connection, rec_data[:])
      }
    }
    else {
      game.connections[received.name] = received
      send_data(&received.connection, []u8{ship_index, 1})
      ship_index += 1
    }
  } else {

    //Send your ships controls to server
    data := []u8{ship_index, transmute(u8)ships[ship_index].controls} 
    send_data(game.connection, data)

    ship_data : [2]u8
    received := receive_data(game.connection, ship_data[:])
    if ship_data[0] == u8(len(ships)) {
      append(&ships, create_ship())
      ships[ship_data[0]].id = ship_data[0]
      init_ship(ships[ship_data[0]])
    }

    if ship_index != ship_data[0] {
      ships[ship_data[0]].controls = transmute(Controls)ship_data[1]
    }

    for ship, i in ships {
      update_astroids(&game.astroids, ship, curTime, &game.view)
      update_ship(ship, &game.view)
      if Controls_enum.shoot in ship.controls do shoot_bullet(ship, curTime)
      if Controls_enum.exit  in ship.controls do game.is_running = false
    }
    fmt.println()
  }
}

render :: proc() {

  for ship in ships {
    draw_ship(ship, NEON_GREEN, &game.view)
    draw_bullets(&ship.bullets, NEON_YELLOW, &game.view)
  }
  draw_astroids(&game.astroids, NEON_RED, &game.view)
  render_color_buffer(game.renderer, &game.view)
  clear_color_buffer(0xFF121212, &game.view)

  SDL.RenderPresent(game.renderer)
}

