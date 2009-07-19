require 'rexml/document'

class HCl
  class TimesheetResource
    def self.configure opts = nil
      if opts
        self.login = opts['login']
        self.password = opts['password']
        self.subdomain = opts['subdomain']
      else
        yield self
      end
    end
  
    # configuration accessors
    %w[ login password subdomain ].each do |config_var|
      class_eval <<-EOC
        def self.#{config_var}= arg
          @@#{config_var} = arg
        end
        def self.#{config_var}
          @@#{config_var}
        end
      EOC
    end
  
    def initialize params
      @data = params
    end
  
    def self.perform action
      client = Curl::Easy.new("https://#{subdomain}.harvestapp.com/#{action}")
      client.headers['Accept'] = 'application/xml'
      client.headers['Content-Type'] = 'application/xml'
      client.http_auth_types = Curl::CURLAUTH_BASIC
      client.userpwd = "#{login}:#{password}"
      if client.http_get
        client.body_str
      else
        raise "failed"
      end
    end
  
    def method_missing method, *args
      if @data.key? method.to_sym
        @data[method]
      else
        super
      end
    end
  end
  
  class DayEntry < TimesheetResource
    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      doc = REXML::Document.new perform url
      doc.root.elements.collect('day_entries/day_entry') do |day|
        new(
          day.elements.map { |e| e.name }.inject({}) do |a, f|
            a[f.to_sym] = day.elements[f].text if day.elements[f]
            a
          end
        )
      end
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end
  end
end
