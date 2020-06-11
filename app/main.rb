require 'lib/mode7.rb'


def setup(args)



  args.state.setup_done = true
end


def tick(args)
  setup(args) unless setup_done



end
