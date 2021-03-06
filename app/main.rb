require 'lib/renderer.rb'
require 'lib/trigo.rb'





# ---=== CONSTANTS : ===---
SCREEN_WIDTH          = 1280
SCREEN_HALF_WIDTH     = 640
SCREEN_HEIGHT         = 720
SCREEN_HALF_HEIGHT    = 360

DISPLAY_WIDTH         = 160
DISPLAY_HEIGHT        = 90

TILESHEET             = "/data/big_tiles.png"
TILESHEET_WIDTH       = 16    # in tiles 
TILESHEET_HEIGHT      = 16
TILE_SIZE             = 64    # in pixels

PIXEL_SCALE           = 8
RASTER_HEIGHT         = 70
RASTER_SCAN_MAX       = 1
RASTER_SCAN_MIN       = 1.0/24.0

FOCAL                 = 45.0
NEAR                  = 32#256
CENTER                = 192#32
FAR                   = 512

TRANSLATION_SPEED     = 5
ROTATION_SPEED        = 2.0





# ---=== SETUP : ===---
def setup(args)
  args.state.track            = read_track_data

  args.state.player.x         = 27 * TILE_SIZE 
  args.state.player.y         = 23 * TILE_SIZE
  args.state.player.direction = 0.0
  args.state.player.ux        = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.uy        = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.vx        = -args.state.player.uy
  args.state.player.vy        =  args.state.player.ux
  args.state.player.dx        = TRANSLATION_SPEED * args.state.player.ux
  args.state.player.dy        = TRANSLATION_SPEED * args.state.player.uy
  
  args.state.focal            = FOCAL
  args.state.near             = NEAR
  args.state.far              = FAR
  args.state.center           = CENTER

  args.state.raster_height    = RASTER_HEIGHT

  args.state.renderer         = Mode7::Renderer.new args.state.focal,
                                                    args.state.near,
                                                    args.state.far,
                                                    args.state.center

  args.state.setup_done       = true
end

def read_track_data
  track_csv = $gtk.read_file('/data/track.csv')
  track_csv.split("\n").reverse.map { |line| line.split(',').map { |v| v.to_i } }
end





# ---=== MAIN LOOP : ===---
def tick(args)
  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. User Inputs :
 
  # - 2.1 Player control :
  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  += ROTATION_SPEED
    args.state.player.ux          = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.uy          = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.vx          = -args.state.player.uy
    args.state.player.vy          =  args.state.player.ux
    args.state.player.dx          = TRANSLATION_SPEED * args.state.player.ux
    args.state.player.dy          = TRANSLATION_SPEED * args.state.player.uy
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  -= ROTATION_SPEED
    args.state.player.ux          = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.uy          = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.vx          = -args.state.player.uy
    args.state.player.vy          =  args.state.player.ux
    args.state.player.dx          = TRANSLATION_SPEED * args.state.player.ux
    args.state.player.dy          = TRANSLATION_SPEED * args.state.player.uy
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          += args.state.player.dx
    args.state.player.y          += args.state.player.dy
  end

  # -2.2 Geometry control :


  # --- 3. Rasterizing :

  # DEBUG DEBUG DEBUG !!!

  # Coordinates :
  #args.outputs.labels << [ 20, 700, "map width: #{args.state.track[0].length} - height: #{args.state.track.length}" ]
  #args.outputs.labels << [ 20, 680, "player coords: #{( args.state.player.x / 8 ).floor};#{( args.state.player.y / 8 ).floor}" ]
  

  # - 3.1 Blitting tile map :

  # - Field of view content :
  field_of_view, center = args.state.renderer.compute_field_of_view args.state.player.ux,
                                                                    args.state.player.uy,
                                                                    args.state.player.vx,
                                                                    args.state.player.vy
  scaned_field          = scan_convert  field_of_view 
  field_bounds          = find_bounds   field_of_view

  rectangle = [ field_bounds[0] - field_bounds[0], field_bounds[1] - field_bounds[1], field_bounds[2], field_bounds[3] ]
  args.render_target(:road).width   = field_bounds[2]
  args.render_target(:road).height  = field_bounds[3]


  # DEBUG DEBUG DEBUG :
  args.outputs.labels << [ 20, 700, "Bounds: #{field_bounds[0]}, #{field_bounds[1]}, #{field_bounds[2]}, #{field_bounds[3]}" ] 
  args.outputs.labels << [ 20, 670, "Center: #{center[0]}, #{center[1]} (offset: #{center[0] - field_bounds[0]}, #{center[1] - field_bounds[1]})" ]
  args.render_target(:road).lines <<  [ [ field_of_view[0][0] - field_bounds[0], field_of_view[0][1] - field_bounds[1], field_of_view[1][0] - field_bounds[0], field_of_view[1][1] - field_bounds[1], 255, 0, 255, 255 ],
                                        [ field_of_view[1][0] - field_bounds[0], field_of_view[1][1] - field_bounds[1], field_of_view[2][0] - field_bounds[0], field_of_view[2][1] - field_bounds[1], 255, 0, 255, 255 ],
                                        [ field_of_view[2][0] - field_bounds[0], field_of_view[2][1] - field_bounds[1], field_of_view[3][0] - field_bounds[0], field_of_view[3][1] - field_bounds[1], 255, 0, 255, 255 ],
                                        [ field_of_view[3][0] - field_bounds[0], field_of_view[3][1] - field_bounds[1], field_of_view[0][0] - field_bounds[0], field_of_view[0][1] - field_bounds[1], 255, 0, 255, 255 ] ]
  draw_cross_to_target :road, [ center[0] - field_bounds[0], center[1] - field_bounds[1] ], [255, 0, 255, 255]
  args.render_target(:road).borders << rectangle + [ 255, 0, 0, 255 ]

  base_x  = args.state.player.x.div( TILE_SIZE )
  base_y  = args.state.player.y.div( TILE_SIZE )
  tiles   = []
  scaned_field.each do |bounds|
    break if bounds[0].nil? || bounds[1].nil?

    x     = bounds[0][0] - ( bounds[0][0] % TILE_SIZE )
    max_x = bounds[1][0]
    y     = bounds[0][1] - ( bounds[0][1] % TILE_SIZE )
    until x >= max_x do
      tile_index_x  = base_x + x.div(TILE_SIZE)
      tile_index_y  = base_y + y.div(TILE_SIZE) 
      tile_index    = args.state.track[tile_index_y][tile_index_x] 

      break if tile_index.nil?

      tile_x        = x - ( ( args.state.player.x ) % TILE_SIZE ) + center[0] - field_bounds[0]
      tile_y        = y - ( ( args.state.player.y ) % TILE_SIZE ) + center[1] - field_bounds[1]
      tiles << blit_tile( tile_index, tile_x, tile_y )

      x += TILE_SIZE
    end
  end

  args.render_target(:road).sprites << tiles


  # - 3.2 Rotating :
  puts center
  args.outputs.sprites << { x:              args.state.renderer.far_fov_width - center[0] + field_bounds[0],
  #args.render_target(:scanned_road).sprites <<  { x:              args.state.renderer.far_fov_width - center[0] + field_bounds[0],
                            y:              args.state.renderer.center - args.state.renderer.near         - center[1] + field_bounds[1],
                                                  w:              field_bounds[2],
                                                  h:              field_bounds[3],
                                                  path:           :road,
                                                  angle:          -args.state.player.direction,
                                                  angle_anchor_x: ( center[0] - field_bounds[0] ) / field_bounds[2],
                                                  angle_anchor_y: ( center[1] - field_bounds[1] ) / field_bounds[3] }


  # - 3.2 Mode 7 rasterizing :
  #distance  = 0
  #args.render_target(:scanned_road).sprites <<  args.state.raster_height.times.map do |y|
  #                                                jump      = 10.0 * y / ( args.state.raster_height - 1 ) + 1
  #                                                distance += 1#jump
  #                                                scale     =  1 - ( 0.9 / 80.0 ) * y
  #                                                {  x:         80 - 640 * scale,
  #                                                   y:         y,
  #                                                   w:         1280 * scale,
  #                                                   h:         1,
  #                                                   path:      :rotated_road,
  #                                                   source_x:  0,
  #                                                   source_y:  368 + distance,
  #                                                   source_w:  1280,
  #                                                   source_h:  1 }
  #                                              end

  #args.outputs.sprites << { x:      0,
  #                          y:      0,
  #                          w:      SCREEN_WIDTH,
  #                          h:      SCREEN_HEIGHT,
  #                          path:   :scanned_road,
  #                          source_x: 0,
  #                          source_y: 0,
  #                          source_w: 160,
  #                          source_h: 90 }


  # --- 4. Background :
  args.outputs.solids << [ 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 50, 50, 50, 255 ]
end

def blit_tile(tile_index,x,y)
  { x:        x,
    y:        y,
    w:        TILE_SIZE,
    h:        TILE_SIZE,
    path:     TILESHEET,
    source_x: TILE_SIZE * ( tile_index %   TILESHEET_WIDTH ),
    source_y: 1024 - TILE_SIZE * ( tile_index.div(TILESHEET_WIDTH) + 1 ),
    source_w: TILE_SIZE,
    source_h: TILE_SIZE } 
end

def scan_convert(vertices)
  # 1. Sorting vertices :
  bottom        = vertices.min { |v1,v2| v1[1] <=> v2[1] }
  bottom_index  = vertices.index bottom
  top           = vertices.max { |v1,v2| v1[1] <=> v2[1] }
  top_index     = vertices.index top

  # 2. Scan :
  tile_dy           = ( top[1] - bottom[1] ).div(TILE_SIZE)
  y                 = 0
  left_scan         = []
  right_scan        = []
  left_index        = bottom_index
  right_index       = bottom_index
  next_left_index   = ( bottom_index + 1 ) % 4
  next_right_index  = ( bottom_index - 1 ) % 4
  left_dy           = vertices[next_left_index][1]  - vertices[left_index][1] 
  right_dy          = vertices[next_right_index][1] - vertices[right_index][1] 
  while y < tile_dy do
    raster_y  = bottom[1] + TILE_SIZE * y

    # 2.1 Left scan :
    if left_dy > 0.0 then
      left_dx   = ( vertices[next_left_index][0] - vertices[left_index][0] ) / left_dy
      left_scan << [ vertices[left_index][0] + ( raster_y - vertices[left_index][1] ) * left_dx, bottom[1] + TILE_SIZE * y ]
    end

    # 2.2 Right scan :
    if right_dy > 0.0 then
      right_dx = ( vertices[next_right_index][0] - vertices[right_index][0] ) / right_dy
      right_scan << [ vertices[right_index][0] + ( raster_y - vertices[right_index][1] ) * right_dx, bottom[1] + TILE_SIZE * y ]
    end

    y += 1

    if y * TILE_SIZE + bottom[1] >= vertices[next_left_index][1] then
      left_index        = ( left_index + 1 ) % 4
      next_left_index   = ( left_index + 1 ) % 4
      left_dy           = vertices[next_left_index][1]  - vertices[left_index][1] 
    end

    if y * TILE_SIZE + bottom[1] >= vertices[next_right_index][1] then
      right_index        = ( right_index - 1 ) % 4
      next_right_index   = ( right_index - 1 ) % 4
      right_dy           = vertices[next_right_index][1]  - vertices[right_index][1] 
    end

  end

  # 3. Pack the rasterizing data :
  left_scan.zip right_scan
end

def find_bounds(vertices)
  x_min = vertices.min { |v1,v2| v1[0] <=> v2[0] }[0]
  x_max = vertices.max { |v1,v2| v1[0] <=> v2[0] }[0]
  y_min = vertices.min { |v1,v2| v1[1] <=> v2[1] }[1]
  y_max = vertices.max { |v1,v2| v1[1] <=> v2[1] }[1]

  [ x_min, y_min, x_max - x_min, y_max - y_min ]
end

def inc(v)
  if v >= 2.0 then  v + 1.0
  else              v * 2.0
  end
end

def dec(v)
  if v <= 2.0 then  v / 2.0
  else              v - 1.0
  end
end

def draw_cross(position,color)
  $gtk.args.outputs.lines << [ position[0] - 5, position[1] - 5, position[0] + 5, position[1] + 5 ] + color
  $gtk.args.outputs.lines << [ position[0] - 5, position[1] + 5, position[0] + 5, position[1] - 5 ] + color
end

def draw_cross_to_target(target,position,color)
  $gtk.args.render_target(target).lines << [ position[0] - 5, position[1] - 5, position[0] + 5, position[1] + 5 ] + color
  $gtk.args.render_target(target).lines << [ position[0] - 5, position[1] + 5, position[0] + 5, position[1] - 5 ] + color
end
