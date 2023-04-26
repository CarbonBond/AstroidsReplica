package main 

import "core:os"
import "core:fmt"
import "core:strings"
import "core:mem"

CHUNK_IHDR := make_u32_from_4_u8('I', 'H', 'D', 'R')

PNG_t :: struct {
  width        : u32
  height       : u32

  color_type   : png_color_type
  color_depth  : u32
  color_format : png_format

  buffer       : ^[]u8

  err          : png_error
  state        : png_state
  source       : png_source
}

png_source :: struct {
  buffer : []u8
  owning : bool 
}

png_color_type :: enum{
  LUM  = 0
  RGB  = 2
  LUMA = 4
  RGBA = 6
}

png_format :: enum {
  ERR,
  RGB8,
  RGB16,
  RGBA8,
  RGBA16,
  LUMINANCE1,
  LUMINANCE2,
  LUMINANCE4,
  LUMINANCE8,
  LUMINANCE_A1,
  LUMINANCE_A2,
  LUMINANCE_A4,
  LUMINANCE_A8,
}

png_error :: enum{
  SUCCESS
  MEM
  NOTFOUND
  NOTPNG
  MALFORMED
  UNSUPPORTED
  INTERLACE
  FORMAT
  PARAM
}

png_state :: enum {
  ERR     = -1
  DECODED = 0
  HEADER  = 1
  NEW     = 2
}

png_FromFile :: proc(file: string) -> (png: ^PNG_t, err: png_error) {
  png = new(PNG_t)
  if png == nil {
    err = .MEM
    png = nil
    return
  }

  buffer, success := os.read_entire_file_from_filename(file)
  if success == false do err = .NOTFOUND
  assert(success == false, "Failed to open bmp")

  png.source.buffer = buffer
  png.source.owning = true

  png.state = .NEW

  png.err = .SUCCESS
  err = .SUCCESS

  return
}

png_Decode :: proc(png: ^PNG_t) -> (err: png_error) {
  chunk : u32
  compressed : ^u8
  inflated : ^u8
  compressed_size, compressed_index : u32 = 0, 0
  inflated_size : u32

  if png.err != .SUCCESS do return png.err

  png_ReadHeader(png)
  if png.err   != .SUCCESS do return png.err
  if png.state != .HEADER  do return png.err

  if png.buffer != nil {
    free(png.buffer)
    png.buffer = nil
  }

  chunk = 33

  for chunk < cast(u32)len(png.source.buffer) {
    data : ^u8

    if chunk + 12 > cast(u32)len(png.source.buffer) {
      png.err = .MALFORMED
      return png.err
    }

    length := make_u32_from_u8slice(png.source.buffer[chunk:chunk+4])



  }


  return
}

png_ReadHeader :: proc(png : ^PNG_t){
  if png.err   != .SUCCESS do return
  if png.state != .NEW     do return

  if len(png.source.buffer) < 29 {
    png.err = .NOTPNG
    return
  }

  if png.source.buffer[0] != 137 || png.source.buffer[1] != 80 ||
     png.source.buffer[2] != 78  || png.source.buffer[3] != 71 ||
     png.source.buffer[4] != 13  || png.source.buffer[5] != 10 ||
     png.source.buffer[6] != 26  || png.source.buffer[7] != 10 {
       png.err = .NOTPNG
       return
  }

  if make_u32_from_u8slice(png.source.buffer[12:16]) != CHUNK_IHDR {
    png.err = .MALFORMED
    return 
  }

  png.width       = make_u32_from_u8slice(png.source.buffer[16:20])
  png.height      = make_u32_from_u8slice(png.source.buffer[20:24])
  png.color_depth = u32(png.source.buffer[24])
  png.color_type  = png_color_type(png.source.buffer[25])

  png.color_format = png_DetermineFormat(png) 
  if png.color_format == .ERR {
    png.err = .MALFORMED
    return 
  }

  if png.source.buffer[26] != 0 || png.source.buffer[27] != 0 {
    png.err = .MALFORMED
    return
  }
  if png.source.buffer[28] != 0 {
    png.err = .INTERLACE
    return
  }

  png.state = .HEADER
  return
}

png_DetermineFormat :: proc(png: ^PNG_t) -> (fmt: png_format) {
  switch png.color_type {
    case .LUM:
      switch png.color_depth {
        case 1:
          fmt = .LUMINANCE1
        case 2:
          fmt = .LUMINANCE2
        case 4:
          fmt = .LUMINANCE4
        case 8:
          fmt = .LUMINANCE8
        case:
          fmt = .ERR
      }
    case .LUMA:
      switch png.color_depth {
        case 1:
          fmt = .LUMINANCE_A1
        case 2:
          fmt = .LUMINANCE_A2
        case 4:
          fmt = .LUMINANCE_A4
        case 8:
          fmt = .LUMINANCE_A8
        case:
          fmt = .ERR
      }
    case .RGB:
      switch png.color_depth {
        case 8:
          fmt = .RGB8
        case 16:
          fmt = .RGB16
        case:
          fmt = .ERR
      }
    case .RGBA:
      switch png.color_depth {
        case 8:
          fmt = .RGBA8
        case 16:
          fmt = .RGBA16
        case:
          fmt = .ERR
      }
    case:
      fmt = .ERR
  }

  return
}

make_u32_from_u8slice :: proc(a: []u8) -> u32 {
  return u32(a[0] << 24) | u32(a[1] << 16) | u32(a[2] << 8) | u32(a[3]) 
}
make_u32_from_4_u8 :: proc(a, b, c, d: u8) -> u32 {
  return u32(a << 24) | u32(b << 16) | u32(c << 8) | u32(d) 
}


/*
Image :: struct {
  height: u32 
  width: u32
  data: ^u32
}

Imagepng.ihdr :: struct {
  ihdr: ChunkIHDR
  idat: ChunkIDAT
}

ChunkIHDR :: struct {
  width: u32,
  height: u32,
  bit_depth: u8,
  color_type: u8,
  comp_method: u8,
  filter_method: u8,
  interlace_method: u8
}
ChunkIDAT :: struct {
  deflate_method: u8,
  zlib_fcheck: u8,
  deflate_block: u64,
  zlib_check: u32,
  crc: u8
}

ImageType :: enum {
  BMP,
  png.ihdr
}


load_image :: proc(file: string, type: ImageType) -> (img: Image) {
  switch type {
    case .BMP:
      img = load_bmp(file);
    case .png.ihdr:
      img = load_png.ihdr(file);
  }
  return;
}

load_png.ihdr :: proc(file: string) -> (img: Image) {
  handle, err := os.open(file, os.O_RDONLY, 0)
  assert(err == os.ERROR_NONE, "Failed to open bmp")

  dataArray: [1000]u8
  png.ihdr : ImagePNG

  {
    headerData := dataArray[:8]
    read, err := os.read(handle, headerData) 
    assert(read == len(headerData), "Didn't read enough bytes")
    assert(err == os.ERROR_NONE, "Failed to read bmp")
    assert(headerData[0] == 0x89 && 
           headerData[1] == 'P' &&
           headerData[2] == 'N' &&
           headerData[3] == 'G', 
           "Opened file is not a png.ihdr") 
  }

  chunkName := []u8{0,0,0,0}
  chunkLength := []u8{0,0,0,0} 

  readingFile := true
  for readingFile {
    read, err := os.read(handle, chunkLength) 
    assert(read == len(chunkLength), "Didn't read enough bytes")

    read, err = os.read(handle, chunkName) 
    assert(read == len(chunkName), "Didn't read enough bytes")

    length := (i32(chunkLength[0]) << 24) | (i32(chunkLength[1]) << 16) | 
              (i32(chunkLength[2]) << 8) | i32(chunkLength[3]) 

    name := strings.clone_from_bytes(chunkName)
    defer delete(name)

    data := dataArray[:length]
    read, err = os.read(handle, data[:]) 
    assert(read == len(data), "Didn't read enough bytes")

    switch name {
      case "IHDR":
        png.ihdr.width = (u32(data[0]) << 24) | (u32(data[1]) << 16) | 
                  (u32(data[2]) << 8) | u32(data[3]) 
        png.ihdr.height = (u32(data[4]) << 24) | (u32(data[5]) << 16) | 
                  (u32(data[6]) << 8) | u32(data[7]) 
        img.width = png.ihdr.width
        img.height = png.ihdr.height
        img.data = cast(^u32)mem.alloc(int(img.width) *
                                       int(img.height) *
                                       size_of(u32))

        png.ihdr.bit_depth = data[8]
        png.ihdr.color_type = data[9]
        png.ihdr.comp_method = data[10]
        png.ihdr.filter_method = data[11]
        png.ihdr.interlace_method = data[12]
        fmt.println(png.ihdr)
      case "PLTE":
      case "IDAT":
       switch png.ihdr.filter_method{
         case 0:

       }
        
      case "IEND":
        readingFile = false
      case:
    }

    chunkCRC:= []u8{0,0,0,0}
    read, err = os.read(handle, chunkCRC ) 
    assert(read == len(chunkCRC), "Didn't read enough bytes")

  }

  return
}

load_bmp :: proc(file: string) -> (img: Image) {
  assert(true == false, "BMP load not implemented.")
  handle, err := os.open(file, os.O_RDONLY, 0)
  assert(err == os.ERROR_NONE, "Failed to open bmp")

  pixelArray : u32

  {
    headerData : []u8 = {0,0,0,0,0,0,0,0}
    read : int
    read, err = os.read(handle, headerData) 
    assert(read == len(headerData), "Didn't read enough bytes")
    assert(err == os.ERROR_NONE, "Failed to read bmp")
    assert(headerData[0] == 'B' && headerData[1] == 'M', 
      "Opened file is not a BMP") 

    for i := 0; i < len(headerData); i += 1 {
      fmt.printf("%b ", headerData[i])
    }
  }


  return
}
*/
