require 'chronic'

module HCl
  class CommandError < StandardError; end
  module Utility
    def fail *message
      raise CommandError, message.join(' ')
    end

    def get_task_ids ident, args
      if @settings.key? "task.#{ident}"
        @settings["task.#{ident}"].split(/\s+/)
      else
        [ident, args.shift]
      end
    end

    def get_ident args
      ident = args.detect {|a| a[0] == '@' }
      if ident
        args.delete(ident)
        ident.slice(1..-1)
      else
        args.shift
      end
    end

    def get_task args
      Task.find *get_task_ids(get_ident(args), args)
    end

    def get_starting_time args
      starting_time = args.detect {|x| x =~ /^\+\d*(\.|:)?\d+$/ }
      if starting_time
        args.delete(starting_time)
        time2float starting_time
      end
    end

    def get_date args
      ident_index = args.index {|a| a[0] == '@' }

      unless ident_index.nil?
        Chronic.parse(args.shift(ident_index).join(' '))
      end
    end

    def current_time
      Time.now.strftime('%I:%M %p').downcase
    end

    # Convert from decimal to a string of the form HH:MM.
    #
    # @param [#to_f] hours number of hours in decimal
    # @return [String] of the form "HH:MM"
    def as_hours hours
      minutes = hours.to_f * 60.0
      sprintf "%d:%02d", (minutes / 60).to_i, (minutes % 60).to_i
    end

    # Convert from a time span in hour or decimal format to a float.
    #
    # @param [String] time_string either "M:MM" or decimal
    # @return [#to_f] converted to a floating-point number
    def time2float time_string
      if time_string =~ /:/
        hours, minutes = time_string.split(':')
        hours.to_f + (minutes.to_f / 60.0)
      else
        time_string.to_f
      end
    end
  end
end
