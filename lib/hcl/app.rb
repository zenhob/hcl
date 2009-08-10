## stdlib dependencies
require 'yaml'
require 'rexml/document'
require 'net/http'
require 'net/https'

## gem dependencies
require 'chronic'
require 'trollop'
require 'highline/import'

## app dependencies
require 'hcl/utility'
require 'hcl/commands'
require 'hcl/timesheet_resource'
require 'hcl/project'
require 'hcl/task'
require 'hcl/day_entry'

# Workaround for annoying SSL warning:
#  >> warning: peer certificate won't be verified in this SSL session
# http://www.5dollarwhitebox.org/drupal/node/64
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

module HCl
  class App
    include HCl::Utility
    include HCl::Commands
  
    SETTINGS_FILE = "#{ENV['HOME']}/.hcl_settings"
    CONFIG_FILE = "#{ENV['HOME']}/.hcl_config"
  
    class UnknownCommand < StandardError; end
  
    def initialize
      read_config
      read_settings
    end

    # Run the given command and arguments.
    def self.command *args
      hcl = new.process_args(*args).run
    end

    # Return true if the string is a known command, false otherwise.
    #
    # @param [#to_s] command name of command
    # @return [true, false]
    def command? command
      Commands.instance_methods.include? command.to_s
    end
  
    # Start the application.
    def run
      begin
        if @command
          if command? @command
            result = send @command, *@args
            if not result.nil?
              if result.respond_to? :to_a
                puts result.to_a.join(', ')
              elsif result.respond_to? :to_s
                puts result
              end
            end
          else
            raise UnknownCommand, "unrecognized command `#{@command}'"
          end
        else
          show
        end
      rescue TimesheetResource::Failure => e
        puts "Internal failure. #{e}"
        exit 1
      end
    end
  
    def process_args *args
      Trollop::options(args) do
        stop_on Commands.instance_methods
        banner <<-EOM
HCl is a command-line client for manipulating Harvest time sheets.

Commands:
    hcl show [date]
    hcl tasks
    hcl aliases
    hcl set <key> <value ...>
    hcl unset <key>
    hcl start <task> [msg]
    hcl stop [msg]
    hcl note <msg>

Examples:
    $ hcl tasks
    $ hcl start 1234 4567 this is my log message
    $ hcl set task.mytask 1234 4567
    $ hcl start mytask this is my next log message
    $ hcl show yesterday
    $ hcl show last tuesday

Options:
EOM
      end
      @command = args.shift
      @args = args
      self
    end

    protected
  
    def read_config
      if File.exists? CONFIG_FILE
        config = YAML::load File.read(CONFIG_FILE)
        TimesheetResource.configure config
      elsif File.exists? old_conf = File.dirname(__FILE__) + "/../hcl_conf.yml"
        config = YAML::load File.read(old_conf)
        TimesheetResource.configure config
        write_config config
      else
        config = {}
        puts "Please specify your Harvest credentials.\n"
        config['login'] = ask("Email Address: ")
        config['password'] = ask("Password: ") { |q| q.echo = false }
        config['subdomain'] = ask("Subdomain: ")
        TimesheetResource.configure config
        write_config config
      end
    end
  
    def write_config config
      puts "Writing configuration to #{CONFIG_FILE}."
      File.open(CONFIG_FILE, 'w') do |f|
       f.write config.to_yaml
      end
    end
  
    def read_settings
      if File.exists? SETTINGS_FILE
        @settings = YAML.load(File.read(SETTINGS_FILE))
      else
        @settings = {}
      end
    end
  
    def write_settings
      File.open(SETTINGS_FILE, 'w') do |f|
       f.write @settings.to_yaml
      end
      nil
    end
  end
end

