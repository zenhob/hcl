require 'yaml'
require 'fileutils'

require 'trollop'
require 'highline/import'

module HCl
  class App
    include HCl::Utility
    include HCl::Commands

    HCL_DIR = ENV['HCL_DIR'] || "#{ENV['HOME']}/.hcl"
    SETTINGS_FILE = "#{HCL_DIR}/settings.yml"
    CONFIG_FILE = "#{HCL_DIR}/config.yml"
    OLD_SETTINGS_FILE = "#{ENV['HOME']}/.hcl_settings"
    OLD_CONFIG_FILE = "#{ENV['HOME']}/.hcl_config"

    def initialize
      FileUtils.mkdir_p(HCL_DIR)
      read_config
      read_settings
      self
    end

    # Run the given command and arguments.
    def self.command *args
      new.process_args(*args).run
    end

    # Return true if the string is a known command, false otherwise.
    #
    # @param [#to_s] command name of command
    # @return [true, false]
    def command? command
      Commands.method_defined? command
    end

    # Start the application.
    def run
      request_config if @options[:reauth]
      begin
        if @command
          if command? @command
            result = send @command, *@args
            if not result.nil?
              if result.respond_to? :join
                puts result.join(', ')
              elsif result.respond_to? :to_s
                puts result
              end
            end
          else
            puts start(@command, *@args)
          end
        else
          puts show
        end
      rescue CommandError => e
        $stderr.puts e
        exit 1
      rescue RuntimeError => e
        $stderr.puts "Error: #{e}"
        exit 1
      rescue SocketError => e
        $stderr.puts "Connection failed. (#{e.message})"
        exit 1
      rescue TimesheetResource::ThrottleFailure => e
        $stderr.puts "Too many requests, retrying in #{e.retry_after+5} seconds..."
        sleep e.retry_after+5
        run
      rescue TimesheetResource::AuthFailure => e
        $stderr.puts "Unable to authenticate: #{e}"
        request_config
        run
      rescue TimesheetResource::Failure => e
        $stderr.puts "API failure: #{e}"
        exit 1
      end
    end

    def process_args *args
      @options = Trollop::options(args) do
        stop_on Commands.instance_methods
        version "HCl version #{VERSION}"
        banner <<-EOM
HCl is a command-line client for manipulating Harvest time sheets.

Commands:
    # show all available tasks
    hcl tasks

    # create a task alias
    hcl alias <task_alias> <project_id> <task_id>

    # list task aliases
    hcl aliases

    # start a task using an alias
    hcl [start] @<task_alias> [+<time>] [<message>]

    # add a line to a running timer
    hcl note <message>

    # stop a running timer
    hcl stop [<message>]

    # log a task and time without leaving a timer running
    hcl log @<task_alias> [+<time>] [<message>]

    # resume the last stopped timer or a specific task
    hcl resume [@<task_alias>]

    # delete the current or last running timer
    hcl (cancel | oops | nvm)

    # display the daily timesheet
    hcl [show [<date>]]

Examples:
    hcl alias mytask 1234 4567
    hcl @mytask +:15 Doing a thing that I started 15 minutes ago.
    hcl note Adding a note to my running task.
    hcl stop That's enough for now.
    hcl resume
    hcl show yesterday
    hcl show last tuesday

Options:
EOM
        opt :reauth, "Force refresh of auth details"
      end
      @command = args.shift
      @args = args
      self
    end

    private

    def read_config
      if File.exists? CONFIG_FILE
        config = YAML::load(File.read(CONFIG_FILE)) || {}
        if has_security_command
          load_password config
        end
        TimesheetResource.configure config
      elsif File.exists? OLD_CONFIG_FILE
        config = YAML::load File.read(OLD_CONFIG_FILE)
        TimesheetResource.configure config
        write_config config
      else
        request_config
      end
    end

    def request_config
      config = {}
      puts "Please specify your Harvest credentials.\n"
      config['login'] = ask("Email Address: ").to_s
      config['password'] = ask("Password: ") { |q| q.echo = false }.to_s
      config['subdomain'] = ask("Subdomain: ").to_s
      config['ssl'] = %w(y yes).include?(ask("Use SSL? (y/n): ").downcase)
      TimesheetResource.configure config
      write_config config
    end

    def write_config config
      puts "Writing configuration to #{CONFIG_FILE}."
      if has_security_command
        save_password config
      end
      File.open(CONFIG_FILE, 'w') do |f|
       f.write config.to_yaml
      end
      FileUtils.chmod 0600, CONFIG_FILE
    end

    def read_settings
      if File.exists? SETTINGS_FILE
        @settings = YAML.load(File.read(SETTINGS_FILE))
      elsif File.exists? OLD_SETTINGS_FILE
        @settings = YAML.load(File.read(OLD_SETTINGS_FILE))
        write_settings
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

    def has_security_command
      if @has_security.nil? 
        @has_security = File.exists?('/usr/bin/security') 
      else
        @has_security
      end
    end

    def load_password config
      cmd = "security find-internet-password -l hcl -a '%s' -s '%s.harvestapp.com' -w" % [
        config['login'],
        config['subdomain'],
      ]
      password = `#{cmd}`
      config.update('password'=>password.chomp) if $?.success?
    end

    def save_password config
      if system("security add-internet-password -U -l hcl -a '%s' -s '%s.harvestapp.com' -w '%s'" % [
        config['login'],
        config['subdomain'],
        config['password'],
      ]) then config.delete('password') end
    end
  end
end

