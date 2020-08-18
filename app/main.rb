#require 'lib/mode7.rb'





# ---=== CONSTANTS : ===---
SCREEN_WIDTH          = 1280
SCREEN_HALF_WIDTH     = 640
SCREEN_HEIGHT         = 720
SCREEN_HALF_HEIGHT    = 360

DISPLAY_WIDTH         = 160
DISPLAY_HEIGHT        = 90

TILESHEET             = "/data/big_tiles.png"
TILESHEET_WIDTH       = 32    # in tiles 
TILESHEET_HEIGHT      = 32
TILE_SIZE             = 64    # in pixels

PIXEL_SCALE           = 8
RASTER_HEIGHT         = 70
RASTER_SCAN_MAX       = 1
RASTER_SCAN_MIN       = 1.0/24.0

#ROAD_SIZE             = 636
#ROTATED_ROAD_MAX_SIZE = 900

#CAMERA_OFFSET         = 48
NEAR                  = 32
NEAR_FOCAL            = 80
FAR                   = 512 
FAR_FOCAL             = 400

#FIELD_DEPTH           = 400#120
#FIELD_WIDTH           = 200#60

TRANSLATION_SPEED     = 5#2.5
ROTATION_SPEED        = 2.0





# ---=== SETUP : ===---
def setup(args)
  args.state.track            = read_track_data

  args.state.player.x         = 26 * TILE_SIZE 
  args.state.player.y         = 23 * TILE_SIZE
  args.state.player.direction = 0.0
  args.state.player.ux        = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.uy        = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.vx        = -args.state.player.uy
  args.state.player.vy        =  args.state.player.ux
  args.state.player.dx        = TRANSLATION_SPEED * args.state.player.ux
  args.state.player.dy        = TRANSLATION_SPEED * args.state.player.uy

  #args.state.field_depth      = FIELD_DEPTH
  #args.state.field_width      = FIELD_WIDTH
  
  args.state.near             = NEAR
  args.state.near_focal       = NEAR_FOCAL
  args.state.far              = FAR
  args.state.far_focal        = FAR_FOCAL

  args.state.raster_height    = RASTER_HEIGHT
  #args.state.raster_scan_min  = RASTER_SCAN_MIN
  #args.state.raster_scan_max  = RASTER_SCAN_MAX
  #args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  #args.state.intercept        = RASTER_SCAN_MAX

  #args.state.focal            = FOCAL
  #args.state.height           = RASTER_HEIGHT

  #args.render_target(:road).width   = 720
  #args.render_target(:road).height  = 720
  #args.render_target(:rotated_road).width   = 720
  #args.render_target(:rotated_road).height  = 720

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
  #if args.inputs.keyboard.key_down.one then
  #  args.state.raster_scan_min  = dec(args.state.raster_scan_min) 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  #elsif args.inputs.keyboard.key_down.two then
  #  args.state.raster_scan_min  = inc(args.state.raster_scan_min) 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  #elsif args.inputs.keyboard.key_down.three then
  #  args.state.raster_scan_max  = dec(args.state.raster_scan_max) 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  #  args.state.intercept        = args.state.raster_scan_max

  #elsif args.inputs.keyboard.key_down.four then
  #  args.state.raster_scan_max  = inc(args.state.raster_scan_max) 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  #  args.state.intercept        = args.state.raster_scan_max

  #elsif args.inputs.keyboard.key_down.five then
  #  args.state.raster_height   -= 1 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  #elsif args.inputs.keyboard.key_down.six then
  #  args.state.raster_height   += 1 
  #  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  #end

  # --- 3. Rasterizing :

  # DEBUG DEBUG DEBUG !!!

  # Coordinates :
  args.outputs.labels << [ 20, 700, "map width: #{args.state.track[0].length} - height: #{args.state.track.length}" ]
  args.outputs.labels << [ 20, 680, "player coords: #{( args.state.player.x / 8 ).floor};#{( args.state.player.y / 8 ).floor}" ]
  

  # - 3.1 Blitting tile map :

  # - Field of view bounds :
  #left_bound_x  = args.state.player.ux * args.state.field_depth - args.state.player.vx * args.state.field_width
  #left_bound_y  = args.state.player.uy * args.state.field_depth - args.state.player.vy * args.state.field_width
  #right_bound_x = args.state.player.ux * args.state.field_depth + args.state.player.vx * args.state.field_width
  #right_bound_y = args.state.player.uy * args.state.field_depth + args.state.player.vy * args.state.field_width
  near_left_x   = args.state.player.ux * args.state.near - args.state.player.vx * args.state.near_focal
  near_left_y   = args.state.player.uy * args.state.near - args.state.player.vy * args.state.near_focal
  near_right_x  = args.state.player.ux * args.state.near + args.state.player.vx * args.state.near_focal
  near_right_y  = args.state.player.uy * args.state.near + args.state.player.vy * args.state.near_focal
  far_left_x    = args.state.player.ux * args.state.far  - args.state.player.vx * args.state.far_focal
  far_left_y    = args.state.player.uy * args.state.far  - args.state.player.vy * args.state.far_focal
  far_right_x   = args.state.player.ux * args.state.far  + args.state.player.vx * args.state.far_focal
  far_right_y   = args.state.player.uy * args.state.far  + args.state.player.vy * args.state.far_focal

  # - Field of view content :
  #scan_bounds = rasterize_field_of_view [ 0.0, 0.0 ],
  #                                      [  left_bound_x,  left_bound_y ],
  #                                      [ right_bound_x, right_bound_y ]
  field_of_view = [ [  near_left_x,  near_left_y ],
                    [ near_right_x, near_right_y ],
                    [  far_right_x,  far_right_y ],
                    [   far_left_x,   far_left_y ] ]
  scan_bounds = scan_convert field_of_view 
  #puts scan_bounds

  # DEBUG DEBUG DEBUG :
  args.outputs.lines << [ [  near_left_x/2.0 + 640,  near_left_y/2.0+ 360,  near_right_x/2.0 + 640, near_right_y/2.0 + 360, 255, 0, 255, 255 ],
                          [ near_right_x/2.0 + 640, near_right_y/2.0+ 360,   far_right_x/2.0 + 640,  far_right_y/2.0 + 360, 255, 0, 255, 255 ],
                          [  far_right_x/2.0 + 640,  far_right_y/2.0+ 360,    far_left_x/2.0 + 640,   far_left_y/2.0 + 360, 255, 0, 255, 255 ],
                          [   far_left_x/2.0 + 640,   far_left_y/2.0+ 360,   near_left_x/2.0 + 640,  near_left_y/2.0 + 360, 255, 0, 255, 255 ] ]

  base_x  = ( args.state.player.x / TILE_SIZE ).floor
  base_y  = ( args.state.player.y / TILE_SIZE ).floor
  tiles   = []
  #count   = 0
  scan_bounds.each do |bounds|
    break if bounds[0].nil? || bounds[1].nil?

    draw_cross( args.outputs.lines,
                640 + bounds[0][0]/2.0,
                360 + bounds[0][1]/2.0,
                [ 255, 0, 0, 255 ] )
    #draw_cross( args.outputs.lines,
    #            640 + bounds[1][0]/2.0,
    #            360 + bounds[1][1]/2.0,
    #            [ 0, 255, 0, 255 ] )

    x     = bounds[0][0] - ( bounds[0][0] % TILE_SIZE )
    max_x = bounds[1][0]
    y     = bounds[0][1] - ( bounds[0][1] % TILE_SIZE )
    until x >= max_x do
      tile_index_x  = base_x + x.div(TILE_SIZE)
      tile_index_y  = base_y + y.div(TILE_SIZE) 
      tile_index    = args.state.track[tile_index_y][tile_index_x] 
      break if tile_index.nil?

      #draw_cross( args.outputs.lines,
      #            640 + x,
      #            360 + y,
      #            [ 255, 0, 255, 255 ] )

      tile_x        = x - ( args.state.player.x % TILE_SIZE )
      tile_y        = y - ( args.state.player.y % TILE_SIZE )
      #tile_x        = TILE_SIZE * x - ( args.state.player.x % 8 )
      #tile_y        = TILE_SIZE * y - ( args.state.player.y % 8 )
      #tiles << blit_tile( tile_index, 640 + tile_x, 360 + tile_y )
      ##tiles << blit_tile( tile_index, 360 + tile_x, 360 + tile_y )

      #x += 1
      x += TILE_SIZE
      #count += 1
    end
  end
  #puts count

  #args.render_target(:road).sprites << tiles
  #args.outputs.sprites << tiles


  # - 3.2 Rotating :
  #args.render_target(:rotated_road).sprites << {  x:              0,
  #                                                y:              0,
  #                                                w:              1280,
  #                                                h:              720,
  #                                                path:           :road,
  #                                                angle:          -args.state.player.direction,
  #                                                angle_anchor_x: 0.5,
  #                                                angle_anchor_y: 0.5 }

  #args.outputs.sprites << { x:        0,
  #                          y:        0,
  #                          w:        1280,
  #                          h:        720,
  #                          path:     :rotated_road }


  # - 3.2 Mode 7 rasterizing :
  distance  = 0
  args.render_target(:scanned_road).sprites <<  args.state.raster_height.times.map do |y|
                                                  jump      = 10.0 * y / ( args.state.raster_height - 1 ) + 1
                                                  distance += jump
                                                  scale     =  1 - ( 0.9 / 80.0 ) * y
                                                  {  x:         80 - 640 * scale,
                                                     y:         y,
                                                     w:         1280 * scale,
                                                     h:         1,
                                                     path:      :rotated_road,
                                                     source_x:  0,
                                                     source_y:  368 + distance,
                                                     source_w:  1280,
                                                     source_h:  1 }
  end

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
    source_x:       TILE_SIZE * ( tile_index %   TILESHEET_WIDTH ),
    source_y: 720 - TILE_SIZE * ( tile_index.div(TILESHEET_WIDTH) + 1 ),
    source_w: TILE_SIZE,
    source_h: TILE_SIZE } 
end

def scan_convert(vertices)
  # Sorting vertices :
  bottom        = vertices.min { |v1,v2| v1[1] <=> v2[1] }
  bottom_index  = vertices.index bottom
  top           = vertices.max { |v1,v2| v1[1] <=> v2[1] }
  top_index     = vertices.index top

  #puts "top: #{top} - top index: #{top_index} - bottom: #{bottom} - bottom index: #{bottom_index}"

  # Winding order :
  winding_order = bottom[0] - vertices[ ( bottom_index + 1 ) % 4 ][0] < 0 ? -1 : 1 # % 4, because all our polygons are quads

  # Scan :
  tile_dy           = ( top[1] - bottom[1] ).div(TILE_SIZE)
  y                 = 0
  left_scan         = []
  right_scan        = []
  left_index        = bottom_index
  right_index       = bottom_index
  next_left_index   = ( bottom_index + winding_order ) % 4
  next_right_index  = ( bottom_index - winding_order ) % 4
  left_dy           = vertices[next_left_index][1]  - vertices[left_index][1] 
  right_dy          = vertices[next_right_index][1] - vertices[right_index][1] 
  #puts "top index: #{top_index} - bottom index: #{bottom_index}"
  while y < tile_dy do

    # Left scan :
    if left_dy > 0.0 then
      left_dx = ( vertices[next_left_index][0] - vertices[left_index][0] ) / left_dy
      #left_scan << snap( [ vertices[left_index][0] + ( TILE_SIZE * y + bottom[1] ) * left_dx, bottom[1] + TILE_SIZE * y ] )
      left_scan << [ vertices[left_index][0] + ( TILE_SIZE * y + bottom[1] ) * left_dx, bottom[1] + TILE_SIZE * y ]
    end

    # Right scan :
    if right_dy > 0.0 then
      right_dx = ( vertices[next_right_index][0] - vertices[right_index][0] ) / right_dy
      #right_scan << snap( [ vertices[right_index][0] + ( TILE_SIZE * y + bottom[1] ) * right_dx, bottom[1] + TILE_SIZE * y ] )
      right_scan << [ vertices[right_index][0] + ( TILE_SIZE * y + bottom[1] ) * right_dx, bottom[1] + TILE_SIZE * y ]
    end

    y += 1

    if y * TILE_SIZE + bottom[1] >= vertices[next_left_index][1] then
      left_index        = ( left_index + winding_order ) % 4
      next_left_index   = ( next_left_index + winding_order ) % 4
      left_dy           = vertices[next_left_index][1]  - vertices[left_index][1] 
    end

    if y * TILE_SIZE + bottom[1] >= vertices[next_right_index][1] then
      right_index        = ( right_index - winding_order ) % 4
      next_right_index   = ( next_right_index - winding_order ) % 4
      right_dy           = vertices[next_right_index][1]  - vertices[right_index][1] 
    end

    #puts "#{y}=> left index: #{left_index}->#{next_left_index}; right index: #{right_index}->#{next_right_index}"
  end


  # Scan the left side :
  #left_scan = []
  #index     = bottom_index
  #loop do
  #  # Scan :
  #  next_index  = ( index + winding_order ) % 4
  #  dy          = vertices[next_index][1] - vertices[index][1]
  #  #puts "left scan dy: #{dy}"
  #  if dy > 0.0 then
  #    dx = ( vertices[next_index][0] - vertices[index][0] ) / dy
  #    ( dy.div(TILE_SIZE) + 0 ).times { |i| left_scan << snap( [ vertices[index][0] + TILE_SIZE * i * dx, vertices[index][1] + TILE_SIZE * i ] ) }
  #  end

  #  # Iterate :
  #  break if vertices[next_index] == top
  #  index       = next_index
  #end
  ##puts left_scan

  ## Scan the right side :
  #right_scan  = []
  #index     = bottom_index
  #loop do
  #  # Scan :
  #  next_index  = ( index - winding_order ) % 4
  #  dy          = vertices[next_index][1] - vertices[index][1]
  #  #puts "right scan dy: #{dy}"
  #  if dy > 0.0 then
  #    dx = ( vertices[next_index][0] - vertices[index][0] ) / dy
  #    ( dy.div(TILE_SIZE) + 0 ).times { |i| right_scan << snap( [ vertices[index][0] + TILE_SIZE * i * dx, vertices[index][1] + TILE_SIZE * i ] ) }
  #  end

  #  # Iterate :
  #  break if vertices[next_index] == top
  #  index       = next_index
  #end
  ##puts right_scan
  
  puts "tchigau!!!" if left_scan.length != right_scan.length

  # Pack the rasterizing data :
  left_scan.zip right_scan
end

def clean_left_scan(scan)
  scan.each_cons(2).map do |vertices|
    if vertices[0][1] == vertices[1][1] then
      vertices[0][0] <= vertices[1][0] ? vertices[0] : vertices[1]
    else
      vertices[0]
    end
  end
end

def clean_right_scan(scan)
  
end

def draw_cross(dest,x,y,color)
  dest << [ x - 2, y - 2, x + 2, y + 2 ] + color
  dest << [ x - 2, y + 2, x + 2, y - 2 ] + color
end

def snap(v)
  [ v[0] - ( v[0] % TILE_SIZE ), v[1] - ( v[1] % TILE_SIZE ) ]
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
