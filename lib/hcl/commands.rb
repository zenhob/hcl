require 'chronic'
require 'highline'

module HCl
  module Commands
    class Error < StandardError; end

    def tasks project_code=nil
      tasks = Task.all
      if tasks.empty? # cache tasks
        DayEntry.all
        tasks = Task.all
      end
      tasks.select! {|t| t.project.code == project_code } if project_code
      if tasks.empty?
        fail "No matching tasks."
      end
      tasks.map { |task| "#{task.project.id} #{task.id}\t#{task}" }.join("\n")
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
          "Deleted entry #{entry}."
        else
          fail "Failed to delete #{entry}!"
        end
      else
        fail 'Nothing to cancel.'
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
      "Removed task alias @#{task}."
    end

    def alias task_name, *value
      task = Task.find *value
      if task
        set "task.#{task_name}", *value
        "Added alias @#{task_name} for #{task}."
      else
        fail "Unrecognized project and task ID: #{value.inspect}"
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
        fail "Unknown task alias, try one of the following: ", aliases.join(', ')
      end
      timer = task.start \
        :starting_time => starting_time,
        :note => args.join(' ')
      "Started timer for #{timer} (at #{current_time})"
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
        "Stopped #{entry} (at #{current_time})"
      else
        fail "No running timers found."
      end
    end

    def note *args
      entry = DayEntry.with_timer
      if entry
        if args.empty?
          return entry.notes
        else
          entry.append_note args.join(' ')
          "Added note to #{entry}."
        end
      else
        fail "No running timers found."
      end
    end

    def show *args
      date = args.empty? ? nil : Chronic.parse(args.join(' '))
      total_hours = 0.0
      result = ''
      DayEntry.all(date).each do |day|
        running = day.running? ? '(running) ' : ''
        columns = HighLine::SystemExtensions.terminal_size[0] rescue 80
        result << "\t#{day.formatted_hours}\t#{running}#{day.project}: #{day.notes.lines.to_a.last}\n"[0..columns-1]
        total_hours = total_hours + day.hours.to_f
      end
      result << ("\t" + '-' * 13) << "\n"
      result << "\t#{as_hours total_hours}\ttotal (as of #{current_time})\n"
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
        fail "No matching timer found."
      end
    end

  end
end
