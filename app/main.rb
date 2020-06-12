#require 'lib/mode7.rb'





# ---=== CONSTANTS : ===---
PIXEL_SCALE         = 8
SCREEN_HALF_WIDTH   = ( 1280 / PIXEL_SCALE ) / 2
SCREEN_HALF_HEIGHT  = 60#(  720 / PIXEL_SCALE ) / 2 





# ---=== SETUP : ===---
def setup(args)
  args.state.player.x         = 480 - 72 
  args.state.player.y         = 128
  args.state.player.direction = 0.0
  args.state.player.dx        = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
  args.state.player.dy        = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )

  args.state.focal            = 80
  args.state.height           = SCREEN_HALF_HEIGHT

  args.state.setup_done       = true

  puts 'setup done'
end





# ---=== MAIN LOOP : ===---
def tick(args)
  setup(args) unless args.state.setup_done


  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  -= 1.5
    args.state.player.dx          = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  += 1.5
    args.state.player.dx          = 5 * Math::cos( args.state.player.direction.to_radians + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( args.state.player.direction.to_radians + Math::PI/2.0 )
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          -= args.state.player.dx
    args.state.player.y          += args.state.player.dy
  end


  args.render_target(:road).sprites << {  x:              340 - args.state.player.x,
                                          y:              340 - args.state.player.y,
                                          w:              480,
                                          h:              480,
                                          path:           'sprites/track_test.png',
                                          angle:          args.state.player.direction,
                                          angle_anchor_x: args.state.player.x / 480.0,
                                          angle_anchor_y: args.state.player.y / 480.0 }
  args.render_target(:road).lines << [ 320,
                                       320,
                                       360,
                                       360,
                                       0, 255, 0, 255 ]
  args.render_target(:road).lines << [ 320,
                                       360,
                                       360,
                                       320,
                                       255, 0, 0, 255 ]

  #args.outputs.sprites << { x:      0,
  #                          y:      0,
  #                          w:      1280,
  #                          h:      720,
  #                          path:   :road }

  #45.times do |y|
  #  args.outputs.sprites << { x:      640,
  #                            y:      200+y,
  #                            w:      1280,
  #                            h:      1,
  #                            path:   :road,
  #                            tile_x: 0,
  #                            tile_y: 720 - 340 - y,
  #                            tile_w: 1280,
  #                            tile_h: 1 }
  #end
 
  SCREEN_HALF_HEIGHT.downto(1) do |y|
    #distance    = Math::sqrt(SCREEN_HALF_HEIGHT ** 2 + ( args.state.focal * args.state.height / y ) )
    distance    = args.state.focal * args.state.height / y
    #slice_width = 480.0 / ( args.state.focal * args.state.height / ( y * SCREEN_HALF_WIDTH ) )
    #slice_width = 480.0 / ( distance / SCREEN_HALF_WIDTH )
    slice_width = SCREEN_HALF_WIDTH * 480.0 / distance
    args.outputs.sprites << { x:      0,
                              y:      8 * y,
                              w:      1280,
                              h:      8,
                              path:   :road,
                              tile_x: 340 - slice_width / 2.0,
                              #tile_y: 720 - 340 - distance,
                              tile_y: 720 - 340 - y,
                              tile_w: slice_width,
                              tile_h: 1 }
  end
 
  #args.outputs.lines << [ 340, 320, 340, 360, 0, 0, 0, 255 ]
  #args.outputs.lines << [ 320, 340, 360, 340, 0, 0, 0, 255 ]
  args.outputs.solids << [ 0, SCREEN_HALF_HEIGHT * PIXEL_SCALE, 1279, 719, 100, 150, 255, 255 ]
end

def compute_fisheye_correction_factors(height,focal)
  height.times do |y|
  end
end

