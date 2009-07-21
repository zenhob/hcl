require 'yaml'
require 'rexml/document'
require 'net/http'
require 'net/https'

require 'rubygems'
require 'chronic'
require 'trollop'

require 'hcl/timesheet_resource'
require 'hcl/project'
require 'hcl/task'
require 'hcl/day_entry'

class HCl
  VERSION = "0.1.0"
  SETTINGS_FILE = "#{ENV['HOME']}/.hcl_settings"

  class UnknownCommand < StandardError; end

  def self.conf_file= filename
    @@conf_file = filename
  end

  def self.command *args
    hcl = new(@@conf_file).process_args(*args).run
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

  def initialize conf_file
    config = YAML::load File.read(conf_file)
    TimesheetResource.configure config
    read_settings
  end

  def process_args *args
    Trollop::options(args) do
      version "HCl #{VERSION}"
      banner <<-EOM
HCl is a command-line client for manipulating Harvest time sheets.

Commands:
    hcl show [date]
    hcl tasks
    hcl add <task> <duration> [msg]
    hcl rm [entry_id]
    hcl start <task> [msg]
    hcl stop [msg]

Examples:
    $ hcl tasks
    $ hcl start 1234 this is my log message
    $ hcl show yesterday
    $ hcl show last tuesday

Options:
EOM
      stop_on %w[ show tasks set unset add rm start stop ]
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

  def read_settings
    settings_file = "#{ENV['HOME']}/.hcl_settings"
    if File.exists? settings_file
      @settings = YAML.load(File.read(settings_file))
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

  def show *args
    date = args.empty? ? nil : Chronic.parse(args.join(' '))
    total_hours = 0.0
    DayEntry.all(date).each do |day|
      # TODO more information and formatting options
      puts "\t#{as_hours day.hours}\t#{day.project} #{day.notes}"[0..78]
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
  alias stop not_implemented
  alias add not_implemented
  alias rm not_implemented

end

