###
Author:  Lyall Jonathan Di Trapani
LJD 16-bit Computer
Creates and populates RAM for video integration testing
---------|---------|---------|---------|---------|---------|---------|--
###
RAM_TILE1 = [
  parseInt '00011011' + '11100100', 2
  parseInt '11111111' + '11111111', 2
  parseInt '00000000' + '11111111', 2
  parseInt '01010101' + '11111111', 2
  parseInt '00000000' + '10101010', 2
  parseInt '00000000' + '00000000', 2
  parseInt '00000000' + '00000000', 2
  parseInt '11100100' + '00011011', 2
]

# To be used as a sprite
# T: Transparent;  Y: Yellow;  M: Magenta;  W: White
RAM_TILE2 = [
  parseInt '11111100' + '11000110', 2   # TTTY TYMW
  parseInt '11000000' + '01010111', 2   # TYYY MMMT
  parseInt '11000000' + '01010111', 2   # TYYY MMMT
  parseInt '11000000' + '01010111', 2   # TYYY MMMT
  parseInt '11111111' + '10101010', 2   # TTTT WWWW
  parseInt '11111111' + '10101010', 2   # TTTT WWWW
  parseInt '11111111' + '10101010', 2   # TTTT WWWW
  parseInt '11111111' + '10101010', 2   # TTTT WWWW
]

RAM_TILE3 = [
  parseInt '01010101' + '01010101', 2
  parseInt '01010101' + '01010101', 2
  parseInt '01011111' + '11110101', 2
  parseInt '01011111' + '11110101', 2
  parseInt '01011111' + '11110101', 2
  parseInt '01011111' + '11110101', 2
  parseInt '01010101' + '01010101', 2
  parseInt '01010101' + '01010101', 2
]

RAM_TILE4 = [
  parseInt '11111111' + '11111111', 2
  parseInt '11111111' + '11111111', 2
  parseInt '11110101' + '01011111', 2
  parseInt '11110101' + '01011111', 2
  parseInt '11110101' + '01011111', 2
  parseInt '11110101' + '01011111', 2
  parseInt '11111111' + '11111111', 2
  parseInt '11111111' + '11111111', 2
]


makeSprite = (tile, cp1, cp2, xy, xpos, ypos) ->
  word1 = tile << 8 | cp1 << 4 | cp2
  word0 = xy << 14 | xpos << 8 | ypos
  [word1, word0]

makeXYFlip = (args...) ->
  value = 0
  for a, i in args
    value |= a << ((7 - i) * 2)
  value

setRAM = (ram, startAddress, values) ->
  ram[startAddress...(startAddress + values.length)] = values


ljd.makeRAM = () ->
  Video = ljd.Video
  ram = (0 for _ in [0...(Math.pow(2, 16))])

  addressOfTile2 = Video.TILE_INDEX + (Video.TILE_INDEX_STEP * 2)
  setRAM ram, addressOfTile2, RAM_TILE1
  addressOfTile3 = Video.TILE_INDEX + (Video.TILE_INDEX_STEP * 3)
  setRAM ram, addressOfTile3, RAM_TILE2
  addressOfTile255 = Video.TILE_INDEX + (Video.TILE_INDEX_STEP * 255)
  setRAM ram, addressOfTile255, RAM_TILE3
  addressOfTile5 = Video.TILE_INDEX + (Video.TILE_INDEX_STEP * 5)
  setRAM ram, addressOfTile5, RAM_TILE4

  cellColors = [
    parseInt('00000' + '00000' + '00000', 2) # Black
    parseInt('11111' + '00000' + '00000', 2) # Red
    parseInt('00000' + '11111' + '00000', 2) # Green
    parseInt('00000' + '00000' + '11111', 2) # Blue
  ]
  setRAM ram, Video.TILE_COLORS, cellColors
  lastCellColors = [
    parseInt('10000' + '10000' + '10000', 2) # Grey
    parseInt('11111' + '00100' + '10000', 2) # Pink
  ]
  setRAM ram, (Video.TILE_COLORS + 15 * 2), lastCellColors
  spriteColors = [
    parseInt('11111' + '11111' + '11111', 2) # White
    parseInt('00000' + '10000' + '10000', 2) # Cyan
    parseInt('10101' + '10101' + '00000', 2) # Yellow
    parseInt('10000' + '00000' + '10000', 2) # Magenta
  ]
  setRAM ram, Video.SPRITE_COLORS, spriteColors

  gridCells = [
    #gridCell:tileIndex;colorPair1;colorPair2
    parseInt('00000010' + '0001' + '0000', 2)
    parseInt('00000010' + '0001' + '0000', 2)
    parseInt('00000010' + '0001' + '0000', 2)
    parseInt('00000010' + '0001' + '0000', 2)
    parseInt('00000010' + '0000' + '0001', 2)
    parseInt('00000010' + '0000' + '0001', 2)
    parseInt('00000010' + '0000' + '0001', 2)
    parseInt('00000010' + '0000' + '0001', 2)
    parseInt('00000100' + '0000' + '0001', 2)
  ]
  setRAM ram, Video.GRID_CELLS, gridCells
  ram[Video.GRID_CELLS + 2399] =
    #        tile # 255   cp1=15   cp2=10
    parseInt('11111111' + '1111' + '1010', 2)

  ram[Video.CELL_X_Y_FLIP] = makeXYFlip(0, 2, 1, 3, 0, 0, 0, 0)

  spriteData = [
    # tile cp1 cp2  XY xpos ypos
    [    3,  1,  0,  0,   4,   0]
    [    3,  1,  0,  2,   5,   0]
    [    3,  1,  0,  1,   6,   0]
    [    3,  1,  0,  3,   7,   0]
    [  255,  0,  1,  0,  59,  38]
    [  255,  0,  1,  0,  58,  39]
    [    5,  1,  1,  0,   0,   0]
  ]
  for [tile, cp1, cp2, xy, xpos, ypos], i in spriteData
    sprite = makeSprite(tile, cp1, cp2, xy, xpos, ypos)
    setRAM ram, (Video.SPRITES + (i * 2)), sprite

  program = [
    # RA gets address of grid cell {x: 0, y: 1} (cell # 60)
    0x1F4A  # 0 HBY $F4 RA      $FA -> Upper(RA)
    0x23CA  # 1 LBY $CA RA      $CA -> Lower(RA)
    # R0 gets value for grid cell {x: 0, y: 1}
    # Tile: 5     cp1: 1     cp2: 15
    # Pink 'O' with blue center
    0x1050  # 2 HBY $05 R0      $05 -> Upper(R0)
    0x21F0  # 3 LBY $1F R0      $1F -> Lower(R0)
    # Grid cell {x: 0, y: 1} gets R0
    0x4A00  # 4 STR RA R0       R0 -> M[RA]
    0x0000  # 5 END             Halt program
  ]
  setRAM ram, 0, program

  ram

ljd.RAM_TILE = RAM_TILE1
