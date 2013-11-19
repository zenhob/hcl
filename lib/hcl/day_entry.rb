
module HCl 
  class DayEntry < TimesheetResource
    include Utility

    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      from_xml get(url)
    end

    def to_s
      "#{client} - #{project} - #{task} (#{formatted_hours})"
    end

    def self.from_xml xml
      doc = REXML::Document.new xml
      raise Failure, "No root node in XML document: #{xml}" if doc.root.nil?
      Task.cache_tasks doc
      doc.root.elements.collect('//day_entry') do |day|
        new xml_to_hash(day)
      end
    end

    def notes
      super || @data[:notes] = ''
    end

    # Append a string to the notes for this task.
    def append_note new_notes
      # If I don't include hours it gets reset.
      # This doens't appear to be the case for task and project.
      (self.notes << "\n#{new_notes}").lstrip!
      DayEntry.post "daily/update/#{id}",
        %{<request><notes>#{notes}</notes><hours>#{hours}</hours></request>}
    end

    def self.with_timer
      all.detect {|t| t.running? }
    end

    def self.last_by_task project_id, task_id
      all.sort {|a,b| b.updated_at<=>a.updated_at}.
        detect {|t| t.project_id == project_id && t.task_id == task_id }
    end

    def self.last
      all.sort {|a,b| a.updated_at<=>b.updated_at}[-1]
    end

    def running?
      !@data[:timer_started_at].nil? && !@data[:timer_started_at].empty?
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end

    def toggle
      DayEntry.get("daily/timer/#{id}")
      self
    end

    # Returns the hours formatted as "HH:MM"
    def formatted_hours
      as_hours hours
    end
  end
end
