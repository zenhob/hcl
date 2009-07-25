require 'yaml'
require 'rexml/document'
require 'net/http'
require 'net/https'

require 'chronic'
require 'trollop'
require 'highline/import'

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

class HCl
  VERSION_FILE = File.dirname(__FILE__) + '/../VERSION.yml'
  SETTINGS_FILE = "#{ENV['HOME']}/.hcl_settings"
  CONFIG_FILE = "#{ENV['HOME']}/.hcl_config"

  class UnknownCommand < StandardError; end

  def self.command *args
    hcl = new.process_args(*args).run
  end

  def run
    if @command
      if respond_to? @command
        send @command, *@args
      else
        raise UnknownCommand, "unrecognized command `#{@command}'"
      end
    else
      show
    end
  end

  def initialize
    @version = YAML::load(File.read(VERSION_FILE))
    read_config
    read_settings
  end

  def version
    [:major, :minor, :patch].map { |v| @version[v] }.join('.')
  end

  def process_args *args
    version_string = version
    Trollop::options(args) do
      version "HCl #{version_string}"
      stop_on %w[ show tasks set unset note add rm start stop ]
      banner <<-EOM
HCl is a command-line client for manipulating Harvest time sheets.

Commands:
    hcl show [date]
    hcl tasks
    hcl set <key> <value ...>
    hcl start <task> [msg]
    hcl stop [msg]
    hcl note <msg>
    hcl add <task> <duration> [msg]
    hcl rm [entry_id]

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

  def tasks
    Task.all.each do |task|
      # TODO more information and formatting options
      puts "#{task.project.id} #{task.id}\t#{task}"
    end
  end

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
  end

  def set key = nil, *args
    if key.nil?
      @settings.each do |k, v|
        puts "#{k}: #{v}"
      end
    else
      value = args.join(' ')
      @settings ||= {}
      @settings[key] = value
      write_settings
    end
  end

  def unset key
    @settings.delete key
    write_settings
  end

  def start *args
    ident = args.shift
    task = if @settings["task.#{ident}"]
      Task.find *@settings["task.#{ident}"].split(/\s+/)
    else
      Task.find ident, args.shift
    end
    task.start(*args)
    puts "Started timer for #{task}"
  end

  def stop
    entry = DayEntry.with_timer
    if entry
      entry.toggle
      puts "Stopped #{entry}"
    else
      puts "No running timers found."
    end
  end

  def note *args
    message = args.join ' '
    entry = DayEntry.with_timer
    if entry
      entry.append_note message
      puts "Added note '#{message}' to #{entry}."
    else
      puts "No running timers found."
    end
  end

  def show *args
    date = args.empty? ? nil : Chronic.parse(args.join(' '))
    total_hours = 0.0
    DayEntry.all(date).each do |day|
      # TODO more information and formatting options
      running = day.running? ? '(running) ' : ''
      puts "\t#{as_hours day.hours}\t#{running}#{day.project} #{day.notes}"[0..78]
      total_hours = total_hours + day.hours.to_f
    end
    puts "\t" + '-' * 13
    puts "\t#{as_hours total_hours}\ttotal"
  end

  # Convert from decimal to a string of the form HH:MM.
  def as_hours hours
    minutes = hours.to_f * 60.0
    sprintf "%d:%02d", (minutes / 60).to_i, (minutes % 60).to_i
  end

  def not_implemented *args
    puts "not yet implemented"
  end

  # TODO implement the following commands
  alias add not_implemented
  alias rm not_implemented

end

