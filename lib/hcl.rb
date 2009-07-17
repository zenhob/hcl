require 'yaml'

require 'rubygems'
require 'curb'

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
        hcl.send command
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

    hcl [opts] add <project> <task> <duration> [msg]
    hcl [opts] rm [entry_id]
    hcl [opts] start <project> <task> [msg]
    hcl [opts] stop [msg]
    hcl [opts] show [date]
    EOM
  end
  def help; self.class.help; end

  def process_args *args
    # TODO process command-line args
    self
  end

  def show
    total_hours = 0.0
    DayEntry.all.each do |day|
      # TODO more information and formatting options
      puts "\t#{day.hours}\t#{day.project} (#{day.notes})"[0..78]
      total_hours = total_hours + day.hours.to_f
    end
    puts "\t" + '-' * 13
    puts "\t#{total_hours}\ttotal"
  end

  def not_implemented
    puts "not yet implemented"
  end

  # TODO implement the following commands
  alias start not_implemented
  alias stop not_implemented
  alias add not_implemented
  alias rm not_implemented

end

