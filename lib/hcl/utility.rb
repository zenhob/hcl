module HCl
  module Utility
    # Convert from decimal to a string of the form HH:MM.
    def as_hours hours
      minutes = hours.to_f * 60.0
      sprintf "%d:%02d", (minutes / 60).to_i, (minutes % 60).to_i
    end

    def time2float time_string
      if time_string =~ /:/
        hours, minutes = time_string.split(':')
        hours.to_f + (minutes.to_f / 60.0)
      elsif time_string =~ /./
        time_string.to_f
      end
    end
  end
end
