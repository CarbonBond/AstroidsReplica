package main 

import "core:os"
import "core:fmt"
import "core:strings"

Bitmap :: struct {
  height: i32 
  width: i32
  data: rawptr
}

ImagePNG :: struct {
  width: u32,
  height: u32,
  bit_depth: u8,
  color_type: u8,
  comp_method: u8,
  filter_method: u8,
  interlace_method: u8
}

Image :: enum {
  BMP,
  PNG
}


load_image :: proc(file: string, type: Image) -> (data: rawptr) {
  switch type {
    case .BMP:
      data = load_bmp(file);
    case .PNG:
      data = load_png(file);
  }
  return;
}

load_png :: proc(file: string) -> (data: rawptr) {
  handle, err := os.open(file, os.O_RDONLY, 0)
  assert(err == os.ERROR_NONE, "Failed to open bmp")

  dataArray: [1000]u8
  png : ImagePNG

  {
    headerData := dataArray[:8]
    read, err := os.read(handle, headerData) 
    assert(read == len(headerData), "Didn't read enough bytes")
    assert(err == os.ERROR_NONE, "Failed to read bmp")
    assert(headerData[0] == 0x89 && 
           headerData[1] == 'P' &&
           headerData[2] == 'N' &&
           headerData[3] == 'G', 
           "Opened file is not a PNG") 
  }

  chunkName := dataArray[:4]
  chunkLength := dataArray[4:8] 
  for {
    read, err := os.read(handle, chunkLength) 
    assert(read == len(chunkLength), "Didn't read enough bytes")

    read, err = os.read(handle, chunkName) 
    assert(read == len(chunkName), "Didn't read enough bytes")

    length := (i32(chunkLength[0]) << 24) | (i32(chunkLength[1]) << 16) | 
              (i32(chunkLength[2]) << 8) | i32(chunkLength[3]) 

    name := strings.clone_from_bytes(chunkName)
    defer delete(name)

    switch name {
      case "IHDR":
        data := dataArray[:length]
        read, err = os.read(handle, data[:]) 
        assert(read == len(data), "Didn't read enough bytes")

        png.width = (u32(data[0]) << 24) | (u32(data[1]) << 16) | 
                  (u32(data[2]) << 8) | u32(data[3]) 
        png.height = (u32(data[4]) << 24) | (u32(data[5]) << 16) | 
                  (u32(data[6]) << 8) | u32(data[7]) 
        png.bit_depth = data[8]
        png.color_type = data[9]
        png.comp_method = data[10]
        png.filter_method = data[11]
        png.interlace_method = data[12]
    }

    break
  }

  return
}

load_bmp :: proc(file: string) -> (data: rawptr) {
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
