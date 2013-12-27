require 'pp'
require 'pry'

module HCl
  class Console
    attr_reader :hcl
    def initialize app
      @hcl = app
      prompt = $PROGRAM_NAME.split('/').last + "> "
      columns = HighLine::SystemExtensions.terminal_size[0] rescue 80
      binding.pry quiet: true,
        prompt:[->(a,b,c){ prompt }],
        print:->(io, *p){ PP.pp p, io, columns }
    end

    Commands.instance_methods.each do |command|
      define_method command do |*args|
        puts @hcl.send(command, *args)
      end
    end
  end
end
