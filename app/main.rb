#require 'lib/mode7.rb'
#require 'data/big_track_test.rb'
#require 'data/test_array.rb'

#puts @an_array





# ---=== CONSTANTS : ===---
SCREEN_WIDTH          = 1280
SCREEN_HALF_WIDTH     = 640
SCREEN_HEIGHT         = 720
SCREEN_HALF_HEIGHT    = 360

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
  #track_file  = File.open('/data/big_track_test.rb', 'r')
  #track_file  = File.open('/data/test_array.rb', 'r')
  #track_data  = track_file.read
  #track_file.close
  #track_data  = args.gtk.read_file('/data/big_track_test.rb')
  #
  #instance_eval track_data

  args.state.player.x         = ROAD_SIZE - 176 
  args.state.player.y         = 192
  args.state.player.direction = 0.0
  args.state.player.dx        = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.dy        = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )

  args.state.raster_height    = RASTER_HEIGHT
  args.state.raster_scan_min  = RASTER_SCAN_MIN
  args.state.raster_scan_max  = RASTER_SCAN_MAX
  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  args.state.intercept        = RASTER_SCAN_MAX

  args.state.focal            = FOCAL
  args.state.height           = RASTER_HEIGHT

  args.state.setup_done       = true
end





# ---=== MAIN LOOP : ===---
def tick(args)
  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. User Inputs :
 
  # - 2.1 Player control :
  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  -= ROTATION_SPEED
    args.state.player.dx          = TRANSLATION_SPEED * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = TRANSLATION_SPEED * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  += ROTATION_SPEED
    args.state.player.dx          = TRANSLATION_SPEED * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = TRANSLATION_SPEED * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          -= args.state.player.dx
    args.state.player.y          += args.state.player.dy
  end

  # -2.2 Geometry control :
  if args.inputs.keyboard.key_down.one then
    args.state.raster_scan_min  = dec(args.state.raster_scan_min) 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.two then
    args.state.raster_scan_min  = inc(args.state.raster_scan_min) 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.three then
    args.state.raster_scan_max  = dec(args.state.raster_scan_max) 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
    args.state.intercept        = args.state.raster_scan_max

  elsif args.inputs.keyboard.key_down.four then
    args.state.raster_scan_max  = inc(args.state.raster_scan_max) 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
    args.state.intercept        = args.state.raster_scan_max

  elsif args.inputs.keyboard.key_down.five then
    args.state.raster_height   -= 1 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.six then
    args.state.raster_height   += 1 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  end

  # --- 3. Rasterizing :
  
  # - 3.1 Rotating :
  args.render_target(:road).sprites << {  x:              ( ROTATED_ROAD_MAX_SIZE >> 1 ) - args.state.player.x,
                                          y:              ( ROTATED_ROAD_MAX_SIZE >> 1 ) - args.state.player.y,
                                          w:              ROAD_SIZE,
                                          h:              ROAD_SIZE,
                                          path:           'data/track_test.png',
                                          angle:          args.state.player.direction,
                                          angle_anchor_x: args.state.player.x / ROAD_SIZE,
                                          angle_anchor_y: ( args.state.player.y + CAMERA_OFFSET ) / ROAD_SIZE }

  # DEBUG DEBUG DEBUG !!!
  #draw_cross( args.render_target(:road).lines,
  #            450,
  #            450,
  #            [ 255, 0, 0, 255 ] )
  #args.outputs.sprites << { x: 0,
  #                          y: 0,
  #                          w: 1280,
  #                          h: 720,
  #                          path: :road }
  #args.outputs.labels << [ 20, 700, "raster height: #{args.state.raster_height} - scan min: #{args.state.raster_scan_min} - scan max: #{args.state.raster_scan_max}" ]


  # - 3.2 Rasterizing :
  args.state.raster_height.times do |y|
    distance    = args.state.focal * args.state.raster_height / ( args.state.raster_height + 1 - y ).to_f
    scale       = args.state.slope * y + args.state.intercept
    args.render_target(:scanned_road).sprites << {  x:      80 - scale * ( ROTATED_ROAD_MAX_SIZE >> 1 ),
                                                    y:      y,
                                                    w:      scale * ROTATED_ROAD_MAX_SIZE,
                                                    h:      1,
                                                    path:   :road,
                                                    tile_x: 0,
                                                    tile_y: 720 - ( ROTATED_ROAD_MAX_SIZE >> 1 ) - distance,
                                                    tile_w: ROTATED_ROAD_MAX_SIZE,
                                                    tile_h: 1 }
  end

  args.outputs.sprites << { x:      0,
                            y:      0,
                            w:      SCREEN_WIDTH,
                            h:      SCREEN_HEIGHT,
                            path:   :scanned_road,
                            tile_x: 0,
                            tile_y: 630,
                            tile_w: 160,
                            tile_h: 90 }


  # --- 4. Background :
  args.outputs.solids << [ 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 100, 150, 255, 255 ]
end

def draw_cross(dest,x,y,color)
  dest << [x-5, y-5, x+5, y+5]+color
  dest << [x-5, y+5, x+5, y-5]+color
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
