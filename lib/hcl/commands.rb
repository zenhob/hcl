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

    def unset key
      @settings.delete key
      write_settings
    end

    def aliases
      @settings.keys.select { |s| s =~ /^task\./ }.map { |s| s.slice(5..-1) }
    end

    def start *args
      starting_time = args.detect {|x| x =~ /^\+\d*(\.|:)?\d+$/ }
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
      puts "Started timer for #{timer} (at #{current_time})"
    end

    def stop *args
      entry = DayEntry.with_timer
      if entry
        entry.append_note(*args.join(' ')) if args.any?
        entry.toggle
        puts "Stopped #{entry} (at #{current_time})"
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
      puts "\t#{as_hours total_hours}\ttotal (as of #{current_time})"
    end

    def resume
      entry = DayEntry.last
      if entry
        puts "Resumed #{entry} (at #{current_time})"
        entry.toggle
      else
        puts "No timers found"
      end
    end

  private
    def current_time
      Time.now.strftime('%I:%M %p').downcase
    end
  end
end
