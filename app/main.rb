#require 'lib/mode7.rb'





# ---=== CONSTANTS : ===---
PIXEL_SCALE         = 8
SCREEN_HALF_WIDTH   = ( 1280 / PIXEL_SCALE ) / 2
RASTER_HEIGHT       = 80
RASTER_SCAN_MAX     = 24 
RASTER_SCAN_MIN     = 1 

ROTATION_SPEED      = 2.0





# ---=== SETUP : ===---
def setup(args)
  args.state.player.x         = 636 - 176#480 - 72 
  args.state.player.y         = 192#128
  args.state.player.direction = 0.0
  args.state.player.dx        = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.dy        = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )

  args.state.raster_height    = RASTER_HEIGHT
  args.state.raster_scan_min  = RASTER_SCAN_MIN
  args.state.raster_scan_max  = RASTER_SCAN_MAX
  #args.state.slope            = ( RASTER_SCAN_MIN - RASTER_SCAN_MAX ) / RASTER_HEIGHT
  args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
  args.state.intercept        = RASTER_SCAN_MAX

  args.state.focal            = 80
  args.state.height           = RASTER_HEIGHT

  args.state.setup_done       = true

  puts 'setup done'
end





# ---=== MAIN LOOP : ===---
def tick(args)
  # --- Setup :
  setup(args) unless args.state.setup_done


  # --- User Inputs :
 
  # Player control :
  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  -= ROTATION_SPEED
    args.state.player.dx          = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  += ROTATION_SPEED
    args.state.player.dx          = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          -= args.state.player.dx
    args.state.player.y          += args.state.player.dy
  end

  # Geometry control :
  if args.inputs.keyboard.key_down.one then
    args.state.raster_scan_min -= 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.two then
    args.state.raster_scan_min += 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.three then
    args.state.raster_scan_max -= 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
    args.state.intercept        = args.state.raster_scan_max

  elsif args.inputs.keyboard.key_down.four then
    args.state.raster_scan_max += 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height
    args.state.intercept        = args.state.raster_scan_max

  elsif args.inputs.keyboard.key_down.five then
    args.state.raster_height   -= 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  elsif args.inputs.keyboard.key_down.six then
    args.state.raster_height   += 2 
    args.state.slope            = ( args.state.raster_scan_min - args.state.raster_scan_max ) / args.state.raster_height

  end

  # --- Rasterizing :
  args.render_target(:road).sprites << {  x:              450 - args.state.player.x,
                                          y:              450 - args.state.player.y,
                                          w:              636,
                                          h:              636,
                                          path:           'sprites/track_test.png',
                                          angle:          args.state.player.direction,
                                          angle_anchor_x: args.state.player.x / 636.0,
                                          angle_anchor_y: ( args.state.player.y + 48 ) / 636.0 }

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


  0.upto(RASTER_HEIGHT) do |y|
    distance    = args.state.focal * args.state.raster_height / ( args.state.raster_height + 1 - y )
    scale       = args.state.slope * y + args.state.intercept
    args.outputs.sprites << { x:      640 - scale * 450,
                              y:      8 * y,
                              w:      scale * 900,
                              h:      8,
                              path:   :road,
                              tile_x: 0,
                              tile_y: 720 - 450 - distance,
                              tile_w: 900,
                              tile_h: 1 }
  end
 

  # --- Background :
  args.outputs.solids << [ 0, 0, 1279, 719, 100, 150, 255, 255 ]
end

def draw_cross(dest,x,y,color)
  dest << [x-5, y-5, x+5, y+5]+color
  dest << [x-5, y+5, x+5, y-5]+color
end
