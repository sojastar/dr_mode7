#require 'lib/mode7.rb'


def setup(args)
  #args.render_target(:road).width   = 91
  #args.render_target(:road).height  = 91

  args.state.setup_done = true
end


def tick(args)
  setup(args) unless args.state.setup_done

  angle = ( args.state.tick_count % 720 ) / 2.0

  args.render_target(:road).sprites << {  x:      16,
                                          y:      16,
                                          w:      64,
                                          h:      64,
                                          path:   'sprites/road_test.png',
                                          angle:  angle }

  args.outputs.sprites << { x:    200,
                            y:    200,
                            w:    1280,
                            h:    720,
                            path: :road }
                            #tile_x: 0,
                            #tile_y: -675,
                            #tile_w: 90,
                            #tile_h: 1 }

  args.outputs.sprites << { x:      400,
                            y:      216,
                            w:      128,
                            h:      2,
                            path:   :road,
                            tile_x: 0,
                            tile_y: 675,
                            tile_w: 90,
                            tile_h: 1 }
  
  args.outputs.lines << [ 200, 200, 200, 500, 0, 0, 0, 25 ]
  args.outputs.lines << [ 200, 200, 500, 200, 0, 0, 0, 25 ]

end
