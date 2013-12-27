module HCl 
  class DayEntry < TimesheetResource
    include Utility

    collection_name :day_entries
    resources :today, 'daily', load_cb:->(data) { Task.cache_tasks_hash data }
    resources(:daily) {|date| date ? "daily/#{date.strftime '%j/%Y'}" : 'daily' }
    resource(:project_info, class_name:'Project') { "projects/#{project_id}" }

    def to_s
      "#{client} - #{project} - #{task} (#{formatted_hours})"
    end

    def task
      @data[:task]
    end

    def cancel
      begin
        Net.delete("daily/delete/#{id}")
      rescue HarvestMiddleware::Failure
        return false
      end
      true
    end

    def notes
      super || @data[:notes] = ''
    end

    # Append a string to the notes for this task.
    def append_note new_notes
      # If I don't include hours it gets reset.
      # This doens't appear to be the case for task and project.
      (self.notes << "\n#{new_notes}").lstrip!
      Net.post "daily/update/#{id}", notes:notes, hours:hours
    end

    def self.with_timer date=nil
      daily(date).detect {|t| t.running? }
    end

    def self.last_by_task project_id, task_id
      today.sort {|a,b| b.updated_at<=>a.updated_at}.
        detect {|t| t.project_id == project_id && t.task_id == task_id }
    end

    def self.last
      today.sort {|a,b| a.updated_at<=>b.updated_at}[-1]
    end

    def running?
      !@data[:timer_started_at].nil? && !@data[:timer_started_at].empty?
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end

    def toggle
      Net.get("daily/timer/#{id}")
      self
    end

    # Returns the hours formatted as "HH:MM"
    def formatted_hours
      as_hours hours
    end
  end
end
