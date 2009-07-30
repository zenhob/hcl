
class HCl 
  class DayEntry < TimesheetResource
    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      from_xml get(url)
    end

    def to_s
      "#{client} #{project} #{task} (#{formatted_hours})"
    end

    def self.from_xml xml
      doc = REXML::Document.new xml
      Task.cache_tasks doc
      doc.root.elements.collect('*/day_entry') do |day|
        new xml_to_hash(day)
      end
    end

    # Append a string to the notes for this task.
    def append_note new_notes
      # If I don't include hours it gets reset.
      # This doens't appear to be the case for task and project.
      DayEntry.post("daily/update/#{id}", <<-EOD)
      <request>
        <notes>#{notes << " #{new_notes}"}</notes>
        <hours>#{hours}</hours>
      </request>
      EOD
    end

    def self.with_timer
      all.detect {|t| t.running? }
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
      self.class.as_hours hours
    end

    # Convert from decimal to a string of the form HH:MM.
    def self.as_hours hours
      minutes = hours.to_f * 60.0
      sprintf "%d:%02d", (minutes / 60).to_i, (minutes % 60).to_i
    end
  end
end
