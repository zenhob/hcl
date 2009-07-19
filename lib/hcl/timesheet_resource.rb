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
      client = session action
      if client.http_get
        client.body_str
      else
        raise "failed"
      end
    end

    def self.send_data action, data
      client = session action
      client.multipart_form_post = true
      data_field = Curl::PostField.file('data','data') { data }
      if client.http_post data_field
        client.body_str
      else
        raise "failed"
      end
    end

    def self.session action
      client = Curl::Easy.new("https://#{subdomain}.harvestapp.com/#{action}")
      client.headers['Accept'] = 'application/xml'
      client.headers['Content-Type'] = 'application/xml'
      client.http_auth_types = Curl::CURLAUTH_BASIC
      client.userpwd = "#{login}:#{password}"
      client
      #client = Patron::Session.new
      #client.timeout = 10
      #client.username = login
      #client.password = password
      #if client.get "https://#{subdomain}.harvestapp.com/#{action}"
    end
  
    def id
      @data[:id]
    end

    def method_missing method, *args
      if @data.key? method.to_sym
        @data[method]
      else
        super
      end
    end

    def self.xml_to_hash elem
      elem.elements.map { |e| e.name }.inject({}) do |a, f|
        a[f.to_sym] = elem.elements[f].text if elem.elements[f]
        a
      end
    end
  end
end
