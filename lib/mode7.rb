module Mode7
  class Renderer
  end
end


set size:
args.render_target(:cached_background).width = 2560
args.render_target(:cached_background).height = 1440


# What does render_target do?
# render_target caches an object to be draw.
# in the parameter we state a name, in this case,
# black but it could be whatever you want it to be.
args.render_target(:black).sprites << [350, 200, 350, 350, '/sprites/bush.png']
# the sprite we want to be drawn is a pre-set up one from the
# sprites folder called bush.
# notice that we aren't actually setting the sprite in the args.output.sprites call
# we are just calling the :black name.
args.outputs.sprites << [350, 200, 350, 350, :black]
# let's call it again next to it and explicitly calling the image location.
args.outputs.sprites << [50, 200, 250, 250, '/sprites/bush.png']


args.render_target(:paragraphTarget).sprites << [0,0,1280,1280,"assets/images/1.jpg"]
for decoParagraph in args.state.paragraphs do
  args.render_target(:paragraphTarget).sprites << decoParagraph.render
end
args.outputs.sprites << [0, 0, 1280, 720, :paragraphTarget]

args.render_target(:paragraphTarget).sprites << args.state.paragraphs.map { |decoParagraph| decoParagraph.render }


#Though at the moment other sizes than the default are a bit difficult to handle because of a bug with the coordinate system (see here for reference: https://discordapp.com/channels/608064116111966245/674410581326823446/702751201263091772 ).... The coordinate origin will always be 720 pixels below the top left corner..... even if your render target height is bigger or smaller than that..... But they are working on that
