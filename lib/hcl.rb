require 'yaml'
require 'rexml/document'
require 'net/http'
require 'net/https'

require 'chronic'
require 'trollop'
require 'highline/import'

require 'hcl/utility'
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
  include Utility

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
    hcl aliases
    hcl set <key> <value ...>
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

  def tasks
    tasks = Task.all
    if tasks.empty?
      puts "No cached tasks. Run `hcl show' to populate the cache and try again."
    else
      tasks.each { |task| puts "#{task.project.id} #{task.id}\t#{task}" }
    end
    nil
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
    nil
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
    nil
  end

  def unset key
    @settings.delete key
    write_settings
  end

  def aliases
    @settings.keys.select { |s| s =~ /^task\./ }.map { |s| s.slice(5..-1) }
  end

  def start *args
    starting_time = args.detect {|x| x =~ /^\+\d*(\.|:)\d+$/ }
    if starting_time
      args.delete(starting_time)
      starting_time = time2float starting_time
    end
    ident = args.shift
    task_ids = if @settings.key? "task.#{ident}"
        @settings["task.#{ident}"].split(/\s+/)
      else
        [ident, args.shift]
      end
    task = Task.find *task_ids
    if task.nil?
      puts "Unknown project/task alias, try one of the following: #{aliases.join(', ')}."
      exit 1
    end
    timer = task.start(:starting_time => starting_time, :note => args.join(' '))
    puts "Started timer for #{timer}."
  end

  def stop
    entry = DayEntry.with_timer
    if entry
      entry.toggle
      puts "Stopped #{entry}."
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
      running = day.running? ? '(running) ' : ''
      puts "\t#{day.formatted_hours}\t#{running}#{day.project} #{day.notes}"[0..78]
      total_hours = total_hours + day.hours.to_f
    end
    puts "\t" + '-' * 13
    puts "\t#{as_hours total_hours}\ttotal"
  end

end

