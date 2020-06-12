#require 'lib/mode7.rb'


def setup(args)
  args.state.player.x         = 480 - 72 
  args.state.player.y         = 128
  args.state.player.direction = 0.0
  args.state.player.dx        = 5 * Math::cos( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
  args.state.player.dy        = 5 * Math::sin( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
  #args.state.player.dx        = 5 * Math::cos( deg_to_rad(args.state.player.direction) )
  #args.state.player.dy        = 5 * Math::sin( deg_to_rad(args.state.player.direction) )

  args.state.setup_done = true

  puts 'setup done'
end


def tick(args)
  setup(args) unless args.state.setup_done


  if    args.inputs.keyboard.key_held.left then
    args.state.player.direction  -= 0.5
    args.state.player.dx          = 5 * Math::cos( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
    #args.state.player.dx          = 5 * Math::cos( deg_to_rad(args.state.player.direction) )
    #args.state.player.dy          = 5 * Math::sin( deg_to_rad(args.state.player.direction) )
  elsif args.inputs.keyboard.key_held.right then
    args.state.player.direction  += 0.5
    args.state.player.dx          = 5 * Math::cos( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
    args.state.player.dy          = 5 * Math::sin( deg_to_rad(args.state.player.direction) + Math::PI/2.0 )
    #args.state.player.dx          = 5 * Math::cos( deg_to_rad(args.state.player.direction) )
    #args.state.player.dy          = 5 * Math::sin( deg_to_rad(args.state.player.direction) )
  end

  if args.inputs.keyboard.key_held.up then
    args.state.player.x          += args.state.player.dx
    args.state.player.y          += args.state.player.dy
  end


  args.render_target(:road).sprites << {  x:      340 - args.state.player.x,
                                          y:      340 - args.state.player.y,
                                          w:      480,
                                          h:      480,
                                          path:   'sprites/track_test.png',
                                          angle:  args.state.player.direction,
                                          angle_anchor_x: args.state.player.x / 480.0,
                                          angle_anchor_y: args.state.player.y / 480.0 }

  450.times do |y|
    args.outputs.sprites << { x:      0,
                              y:      y,
                              w:      680,
                              h:      1,
                              path:   :road,
                              tile_x: 0,
                              tile_y: 720 - y,
                              tile_w: 680,
                              tile_h: 1 }
  end
  
  args.outputs.lines << [ 320, 320, 360, 360, 0, 0, 0, 255 ]
  args.outputs.lines << [ 320, 360, 360, 320, 0, 0, 0, 255 ]
  #args.outputs.lines << [ 340,
  #                        340,
  #                        340 + 10 * args.state.player.dx,
  #                        340 + 10 * args.state.player.dy,
  #                        255, 0, 0, 255 ]

end


def deg_to_rad(angle)
  angle * Math::PI / 180.0
end

def rad_to_deg(angle)
  angle * 180.0 / Math::PI
end
