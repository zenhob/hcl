require 'chronic'
require 'highline'

module HCl
  module Commands
    def tasks
      tasks = Task.all
      if tasks.empty?
        puts "No cached tasks. Run `hcl show' to populate the cache and try again."
      else
        tasks.each { |task| puts "#{task.project.id} #{task.id}\t#{task}" }
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

    def cancel
      entry = DayEntry.with_timer || DayEntry.last
      if entry
        if entry.cancel
          puts "Deleted entry #{entry}."
        else
          puts "Failed to delete #{entry}!"
          exit 1
        end
      else
        puts 'Nothing to cancel.'
        exit 1
      end
    end
    alias_method :oops, :cancel
    alias_method :nvm, :cancel

    def unset key
      @settings.delete key
      write_settings
    end

    def unalias task
      unset "task.#{task}"
        puts "Removed task alias @#{task}."
    end

    def alias task_name, *value
      task = Task.find *value
      if task
        set "task.#{task_name}", *value
        puts "Added alias @#{task_name} for #{task}."
      else
        puts "Unrecognized project and task ID: #{value.inspect}"
        exit 1
      end
    end

    def completion
      %[complete -W "#{aliases.join ' '}" hcl]
    end

    def aliases
      @settings.keys.select { |s| s =~ /^task\./ }.map { |s| "@"+s.slice(5..-1) }
    end

    def start *args
      starting_time = get_starting_time args
      task = get_task args
      if task.nil?
        puts "Unknown task alias, try one of the following: ", aliases.join(', ')
        exit 1
      end
      timer = task.start \
        :starting_time => starting_time,
        :note => args.join(' ')
      puts "Started timer for #{timer} (at #{current_time})"
    end

    def log *args
      start *args
      stop
    end

    def stop *args
      entry = DayEntry.with_timer || DayEntry.with_timer(DateTime.yesterday)
      if entry
        entry.append_note(args.join(' ')) if args.any?
        entry.toggle
        puts "Stopped #{entry} (at #{current_time})"
      else
        puts "No running timers found."
        exit 1
      end
    end

    def note *args
      message = args.join ' '
      entry = DayEntry.with_timer
      if entry
        entry.append_note message
        puts "Added note to #{entry}."
      else
        puts "No running timers found."
        exit 1
      end
    end

    def show *args
      date = args.empty? ? nil : Chronic.parse(args.join(' '))
      total_hours = 0.0
      DayEntry.all(date).each do |day|
        running = day.running? ? '(running) ' : ''
        columns = HighLine::SystemExtensions.terminal_size[0]
        puts "\t#{day.formatted_hours}\t#{running}#{day.project}: #{day.notes.lines.last}"[0..columns-1]
        total_hours = total_hours + day.hours.to_f
      end
      puts "\t" + '-' * 13
      puts "\t#{as_hours total_hours}\ttotal (as of #{current_time})"
    end

    def resume *args
      ident = get_ident args
      entry = if ident
          task_ids = get_task_ids ident, args
          DayEntry.last_by_task *task_ids
        else
          DayEntry.last
        end
      if entry
        entry.toggle
      else
        puts "No matching timer found."
        exit 1
      end
    end

  end
end
