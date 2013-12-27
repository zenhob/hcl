require 'pp'

module HCl
  class Console
    attr_reader :hcl
    def initialize app
      @hcl = app
      binding.pry quiet: true,
        prompt:[->(a,b,c){"#{$PROGRAM_NAME}> "}],
        print:->(io, *p){ pp p }
    end

    Commands.instance_methods.each do |command|
      define_method command do |*args|
        puts @hcl.send(command, *args)
      end
    end
  end
end
