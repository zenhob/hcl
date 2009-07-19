
class HCl 
  class DayEntry < TimesheetResource
    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      doc = REXML::Document.new perform url
      Task.cache_tasks doc
      doc.root.elements.collect('day_entries/day_entry') do |day|
        new xml_to_hash(day)
      end
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end
  end
end
