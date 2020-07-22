#require 'lib/mode7.rb'
#require 'data/big_track_test.rb'
#require 'data/test_array.rb'

#puts @an_array





# ---=== CONSTANTS : ===---
SCREEN_WIDTH          = 1280
SCREEN_HALF_WIDTH     = 640
SCREEN_HEIGHT         = 720
SCREEN_HALF_HEIGHT    = 360

TILESHEET             = "/data/tiles.png"
TILESHEET_WIDTH       = 16    # in tiles 
TILESHEET_HEIGHT      = 16
TILE_SIZE             = 8     # in pixels

PIXEL_SCALE           = 8
RASTER_HEIGHT         = 80
RASTER_SCAN_MAX       = 1
RASTER_SCAN_MIN       = 1.0/24.0

ROAD_SIZE             = 636
ROTATED_ROAD_MAX_SIZE = 900

CAMERA_OFFSET         = 48
FOCAL                 = 80

TRANSLATION_SPEED     = 2.5
ROTATION_SPEED        = 2.0





# ---=== SETUP : ===---
def setup(args)
  args.state.track            = read_track_data

  args.state.player.x         = 234 * TILE_SIZE#ROAD_SIZE - 176 
  args.state.player.y         = 110 * TILE_SIZE#192
  args.state.player.direction = 0.0
  args.state.player.ux        = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.uy        = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.vx        = -args.state.player.uy
  args.state.player.vy        =  args.state.player.ux
  #args.state.player.dx        = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  #args.state.player.dy        = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.dx        = TRANSLATION_SPEED * args.state.player.ux
  args.state.player.dy        = TRANSLATION_SPEED * args.state.player.uy

  args.state.field_depth      = 120
  args.state.field_width      = 60

  args.state.raster_height    = RASTER_HEIGHT
  args.state.raster_scan_min  = RASTER_SCAN_MIN
  args.state.raster_scan_max  = RASTER_SCAN_MAX
  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  args.state.intercept        = RASTER_SCAN_MAX

  args.state.focal            = FOCAL
  args.state.height           = RASTER_HEIGHT

  args.state.setup_done       = true
end

def read_track_data
  track_csv = $gtk.read_file('/data/big_track_test.rb')
  track_csv.split("\n").map { |line| line.split(',').map { |v| v.to_i } }
end





# ---=== MAIN LOOP : ===---
def tick(args)
  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. User Inputs :
 
  # - 2.1 Player control :
  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  -= ROTATION_SPEED
    args.state.player.ux          = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.uy          = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.vx          = -args.state.player.uy
    args.state.player.vy          =  args.state.player.ux
    args.state.player.dx          = TRANSLATION_SPEED * args.state.player.ux#Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = TRANSLATION_SPEED * args.state.player.uy#Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  += ROTATION_SPEED
    args.state.player.ux          = Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.uy          = Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.vx          = -args.state.player.uy
    args.state.player.vy          =  args.state.player.ux
    args.state.player.dx          = TRANSLATION_SPEED * args.state.player.ux#Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = TRANSLATION_SPEED * args.state.player.uy#Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          -= args.state.player.dx
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
  
  # - 3.1 Blitting tile map :


  
  # - 3.1 Rotating :
  #args.render_target(:road).sprites << {  x:              ( ROTATED_ROAD_MAX_SIZE >> 1 ) - args.state.player.x,
  #                                        y:              ( ROTATED_ROAD_MAX_SIZE >> 1 ) - args.state.player.y,
  #                                        w:              ROAD_SIZE,
  #                                        h:              ROAD_SIZE,
  #                                        path:           'data/track_test.png',
  #                                        angle:          args.state.player.direction,
  #                                        angle_anchor_x: args.state.player.x / ROAD_SIZE,
  #                                        angle_anchor_y: ( args.state.player.y + CAMERA_OFFSET ) / ROAD_SIZE }

  # DEBUG DEBUG DEBUG !!!

  # Coordinates :
  args.outputs.labels << [ 20, 700, "map width: #{args.state.track[0].length} - height: #{args.state.track.length}" ]
  args.outputs.labels << [ 20, 680, "player coords: #{( args.state.player.x / 8 ).floor};#{( args.state.player.y / 8 ).floor}" ]

  # u and v :
  args.outputs.lines << [ 640, 360, 640 + 20 * args.state.player.ux, 360 + 20 * args.state.player.uy, 0, 255, 0, 255 ]
  args.outputs.lines << [ 640, 360, 640 + 20 * args.state.player.vx, 360 + 20 * args.state.player.vy, 0, 0, 255, 255 ]

  # field of view bounds :
  left_bound_x  = args.state.player.ux * args.state.field_depth - args.state.player.vx * args.state.field_width
  left_bound_y  = args.state.player.uy * args.state.field_depth - args.state.player.vy * args.state.field_width
  right_bound_x = args.state.player.ux * args.state.field_depth + args.state.player.vx * args.state.field_width
  right_bound_y = args.state.player.uy * args.state.field_depth + args.state.player.vy * args.state.field_width
  args.outputs.lines << [ 640, 360, 640 +  left_bound_x, 360 +  left_bound_y, 255, 0, 0, 255 ]
  args.outputs.lines << [ 640, 360, 640 + right_bound_x, 360 + right_bound_y, 255, 0, 0, 255 ]
  args.outputs.lines << [ 640 + left_bound_x, 360 + left_bound_y, 640 + right_bound_x, 360 + right_bound_y, 255, 0, 0, 255 ]

  scan_bounds = rasterize_field_of_view [ 0.0, 0.0 ],
                                        [  left_bound_x,  left_bound_y ],
                                        [ right_bound_x, right_bound_y ]
  # field of view content :
  #count = 0
  base_x  = ( args.state.player.x / TILE_SIZE ).floor
  base_y  = ( args.state.player.y / TILE_SIZE ).floor
  scan_bounds.each do |bounds|
    break if bounds[0].nil? || bounds[1].nil?

    x     = bounds[0][0]
    max_x = bounds[1][0]
    y     = bounds[0][1]
    until x >= max_x do
      draw_cross args.outputs.lines, 640 + TILE_SIZE * x, 360 + TILE_SIZE * y, [ 255, 0, 255, 255 ]

      tile_index_x  = base_x + x 
      tile_index_y  = base_y + y 
      tile_index    = args.state.track[tile_y][tile_x] 

      x += 1
      #count += 1
    end
  end
  #puts count
  ##draw_cross( args.render_target(:road).lines,
  ##            450,
  ##            450,
  ##            [ 255, 0, 0, 255 ] )
  ##args.outputs.sprites << { x: 0,
  ##                          y: 0,
  ##                          w: 1280,
  ##                          h: 720,
  ##                          path: :road }
  ##args.outputs.labels << [ 20, 700, "raster height: #{args.state.raster_height} - scan min: #{args.state.raster_scan_min} - scan max: #{args.state.raster_scan_max}" ]


  ## - 3.2 Rasterizing :
  #args.state.raster_height.times do |y|
  #  distance    = args.state.focal * args.state.raster_height / ( args.state.raster_height + 1 - y ).to_f
  #  scale       = args.state.slope * y + args.state.intercept
  #  args.render_target(:scanned_road).sprites << {  x:      80 - scale * ( ROTATED_ROAD_MAX_SIZE >> 1 ),
  #                                                  y:      y,
  #                                                  w:      scale * ROTATED_ROAD_MAX_SIZE,
  #                                                  h:      1,
  #                                                  path:   :road,
  #                                                  tile_x: 0,
  #                                                  tile_y: 720 - ( ROTATED_ROAD_MAX_SIZE >> 1 ) - distance,
  #                                                  tile_w: ROTATED_ROAD_MAX_SIZE,
  #                                                  tile_h: 1 }
  #end

  #args.outputs.sprites << { x:      0,
  #                          y:      0,
  #                          w:      SCREEN_WIDTH,
  #                          h:      SCREEN_HEIGHT,
  #                          path:   :scanned_road,
  #                          tile_x: 0,
  #                          tile_y: 630,
  #                          tile_w: 160,
  #                          tile_h: 90 }


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
