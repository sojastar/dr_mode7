#require 'lib/mode7.rb'





# ---=== CONSTANTS : ===---
SCREEN_WIDTH          = 1280
SCREEN_HALF_WIDTH     = 640
SCREEN_HEIGHT         = 720
SCREEN_HALF_HEIGHT    = 360

DISPLAY_WIDTH         = 160
DISPLAY_HEIGHT        = 90

TILESHEET             = "/data/tiles.png"
TILESHEET_WIDTH       = 16    # in tiles 
TILESHEET_HEIGHT      = 16
TILE_SIZE             = 8     # in pixels

PIXEL_SCALE           = 8
RASTER_HEIGHT         = 70
RASTER_SCAN_MAX       = 1
RASTER_SCAN_MIN       = 1.0/24.0

#ROAD_SIZE             = 636
#ROTATED_ROAD_MAX_SIZE = 900

#CAMERA_OFFSET         = 48
#FOCAL                 = 80

FIELD_DEPTH           = 400#120
FIELD_WIDTH           = 100#60

TRANSLATION_SPEED     = 5#2.5
ROTATION_SPEED        = 2.0





# ---=== SETUP : ===---
def setup(args)
  args.state.track            = read_track_data

  args.state.player.x         = 234 * TILE_SIZE 
  args.state.player.y         = 40 * TILE_SIZE
  args.state.player.direction = 0.0
  args.state.player.ux        = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.uy        = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.vx        = -args.state.player.uy
  args.state.player.vy        =  args.state.player.ux
  args.state.player.dx        = TRANSLATION_SPEED * args.state.player.ux
  args.state.player.dy        = TRANSLATION_SPEED * args.state.player.uy

  args.state.field_depth      = FIELD_DEPTH
  args.state.field_width      = FIELD_WIDTH

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
  track_csv = $gtk.read_file('/data/big_track_test.rb')
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
  left_bound_x  = args.state.player.ux * args.state.field_depth - args.state.player.vx * args.state.field_width
  left_bound_y  = args.state.player.uy * args.state.field_depth - args.state.player.vy * args.state.field_width
  right_bound_x = args.state.player.ux * args.state.field_depth + args.state.player.vx * args.state.field_width
  right_bound_y = args.state.player.uy * args.state.field_depth + args.state.player.vy * args.state.field_width

  # - Field of view content :
  scan_bounds = rasterize_field_of_view [ 0.0, 0.0 ],
                                        [  left_bound_x,  left_bound_y ],
                                        [ right_bound_x, right_bound_y ]

  base_x  = ( args.state.player.x / TILE_SIZE ).floor
  base_y  = ( args.state.player.y / TILE_SIZE ).floor
  tiles   = []
  #count   = 0
  scan_bounds.each do |bounds|
    break if bounds[0].nil? || bounds[1].nil?

    x     = bounds[0][0] - 5
    max_x = bounds[1][0] + 5
    y     = bounds[0][1]
    until x >= max_x do
      tile_index_x  = base_x + x 
      tile_index_y  = base_y + y 
      tile_index    = args.state.track[tile_index_y][tile_index_x] 
      break if tile_index.nil?

      tile_x        = TILE_SIZE * x - ( args.state.player.x % 8 )
      tile_y        = TILE_SIZE * y - ( args.state.player.y % 8 )
      tiles << blit_tile( tile_index, 640 + tile_x, 360 + tile_y )
      #tiles << blit_tile( tile_index, 360 + tile_x, 360 + tile_y )

      x += 1
      #count += 1
    end
  end
  #puts count

  args.render_target(:road).sprites << tiles


  # - 3.2 Rotating :
  args.render_target(:rotated_road).sprites << {  x:              0,
                                                  y:              0,
                                                  w:              1280,
                                                  h:              720,
                                                  path:           :road,
                                                  angle:          -args.state.player.direction,
                                                  angle_anchor_x: 0.5,
                                                  angle_anchor_y: 0.5 }

  #args.outputs.sprites << { x:        0,
  #                          y:        0,
  #                          w:        1280,
  #                          h:        720,
  #                          path:     :rotated_road }


  # - 3.2 Mode 7 rasterizing :
  distance  = 0
  args.state.raster_height.times do |y|
    jump      = 10.0 * y / ( args.state.raster_height - 1 ) + 1
    distance += jump
    scale     =  1 - ( 0.9 / 80.0 ) * y
    #puts "scale: #{scale}"
    args.render_target(:scanned_road).sprites << {  x: 80 - 640 * scale,
                                                    y: y,
                                                    w: 1280 * scale,
                                                    h: 1,
                                                    path: :rotated_road,
                                                    source_x: 0,
                                                    source_y: 368 + distance,
                                                    source_w: 1280,
                                                    source_h: 1 }
  end

  args.outputs.sprites << { x:      0,
                            y:      0,
                            w:      SCREEN_WIDTH,
                            h:      SCREEN_HEIGHT,
                            path:   :scanned_road,
                            source_x: 0,
                            source_y: 0,
                            source_w: 160,
                            source_h: 90 }


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

#def rasterize_field_of_view(p1,p2,p3)
#  y_sorted_vertices = [ p1, p2, p3 ].sort_by { |p| p[1] }
#
#  # Scan the simple side :
#  dy                = ( y_sorted_vertices.last[1] - y_sorted_vertices.first[1] ).to_i / TILE_SIZE
#  dx                = ( y_sorted_vertices.last[0] - y_sorted_vertices.first[0] ) / dy
#  simple_scan       = dy.times.map { |i| [ y_sorted_vertices.first[0] + i * dx, TILE_SIZE * i + y_sorted_vertices.first[1] ] }
#
#  # Scan the composite side :
#  dy1               =   y_sorted_vertices[1][1]   - y_sorted_vertices.first[1]
#  dx1               = ( y_sorted_vertices[1][0]   - y_sorted_vertices.first[0] ) / dy1
#  dy2               =   y_sorted_vertices.last[1] - y_sorted_vertices[1][1]
#  dx2               = ( y_sorted_vertices.last[0] - y_sorted_vertices[1][0] )    / dy2
#  composite_scan    = dy.times.map do |i| 
#                        if 8 * i <= dy1 then
#                          [ y_sorted_vertices.first[0] + 8 * i * dx1, 8 * i + y_sorted_vertices.first[1] ]
#                        else
#                          [ y_sorted_vertices[1][0] + ( 8 * i - dy1 ) * dx2, 8 * i + y_sorted_vertices.first[1] ]
#                        end
#                      end
#
#  # Pack the rasterizing data :
#  if y_sorted_vertices[1][0] < y_sorted_vertices.first[0] then  # composite on the left
#    composite_scan.zip  simple_scan
#  else                                                          # composite on the right
#    simple_scan.zip     composite_scan
#  end
#end

def rasterize_field_of_view(p1,p2,p3)
  y_sorted_vertices = [ p1, p2, p3 ].sort_by { |p| p[1] }.map { |p| [ p[0] / TILE_SIZE, p[1] / TILE_SIZE ] }

  # Scan the simple side :
  dy                = ( y_sorted_vertices.last[1] - y_sorted_vertices.first[1] ).to_i
  dx                = ( y_sorted_vertices.last[0] - y_sorted_vertices.first[0] ) / dy
  simple_scan       = dy.times.map { |i| [ ( y_sorted_vertices.first[0] + i * dx ).floor, y_sorted_vertices.first[1].floor + i ] }

  # Scan the composite side :
  composite_scan    = []
  dy1               = ( y_sorted_vertices[1][1] - y_sorted_vertices.first[1] ).round
  if dy1 != 0 then
    dx1 = ( y_sorted_vertices[1][0] - y_sorted_vertices.first[0] ) / dy1
    dy1.times { |i| composite_scan << [ ( y_sorted_vertices.first[0] + i * dx1 ).round, y_sorted_vertices.first[1].round + i ] }
  end

  dy2               = ( y_sorted_vertices.last[1] - y_sorted_vertices[1][1]    ).round
  if dy2 != 0 then
    dx2 = ( y_sorted_vertices.last[0] - y_sorted_vertices[1][0] ) / dy2
    dy2.times { |i| composite_scan << [ ( y_sorted_vertices[1][0] + i * dx2 ).round, y_sorted_vertices[1][1].round + i ] }
  end

  # Pack the rasterizing data :
  if y_sorted_vertices[1][0] < y_sorted_vertices.first[0] then  # composite on the left
    composite_scan.zip  simple_scan
  else                                                          # composite on the right
    simple_scan.zip     composite_scan
  end
end

def draw_cross(dest,x,y,color)
  dest << [ x - 2, y - 2, x + 2, y + 2 ] + color
  dest << [ x - 2, y + 2, x + 2, y - 2 ] + color
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
