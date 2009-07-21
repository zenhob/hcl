require 'yaml'
require 'rexml/document'
require 'net/http'
require 'net/https'

require 'rubygems'
require 'chronic'

require 'hcl/timesheet_resource'
require 'hcl/project'
require 'hcl/task'
require 'hcl/day_entry'

class HCl
  class UnknownCommand < StandardError; end

  def self.conf_file= filename
    @@conf_file = filename
  end

  def self.command *args
    command = args.shift
    hcl = new(@@conf_file).process_args *args
    if command
      if hcl.respond_to? command
        hcl.send command, *args
      else
        raise UnknownCommand, "unrecognized command `#{command}'"
      end
    else
      hcl.show
      return
    end
  end

  def initialize conf_file
    config = YAML::load File.read(conf_file)
    TimesheetResource.configure config
  end

  def self.help
    puts <<-EOM
    Usage:

    hcl show [date]
    hcl tasks
    hcl add <task> <duration> [msg]
    hcl rm [entry_id]
    hcl start <task> [msg]
    hcl stop [msg]

    Examples:

    hcl show 2009-07-15
    hcl show yesterday
    hcl show last tuesday
    EOM
  end
  def help; self.class.help; end

  def process_args *args
    # TODO process command-line args
    self
  end

  def tasks
    Task.all.each do |task|
      # TODO more information and formatting options
      puts "#{task.id}\t#{task}"
    end
  end

  def start *args
    task = Task.find args.shift
    puts "Starting timer for #{task}"
    day_entry = task.start(*args)
    puts "Time is running on #{day_entry}"
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
    "#{(minutes / 60).to_i}:#{(minutes % 60).to_i}"
  end

  def not_implemented *args
    puts "not yet implemented"
  end

  # TODO implement the following commands
  alias stop not_implemented
  alias add not_implemented
  alias rm not_implemented

end

