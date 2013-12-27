require 'pp'
require 'pry'

module HCl
  class Console
    attr_reader :hcl
    def initialize app
      @hcl = app
      prompt = $PROGRAM_NAME.split('/').last + "> "

      binding.pry quiet: true,
        prompt:[->(a,b,c){ prompt }],
        print:->(io, *p){ pp p }
    end

    Commands.instance_methods.each do |command|
      define_method command do |*args|
        puts @hcl.send(command, *args)
      end
    end
  end
end
