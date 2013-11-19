module HCl
  class TimesheetResource
    class Failure < StandardError; end

    def self.configure opts = nil
      if opts
        self.login = opts['login']
        self.password = opts['password']
        self.subdomain = opts['subdomain']
        self.ssl = opts['ssl']
      else
        yield self
      end
    end

    # configuration accessors
    %w[ login password subdomain ssl ].each do |config_var|
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

    def self.get action
      http_do Net::HTTP::Get, action
    end

    def self.post action, data
      http_do Net::HTTP::Post, action, data
    end

    def self.delete action
      http_do Net::HTTP::Delete, action
    end

    def self.http_do method_class, action, data = nil
      https   = Net::HTTP.new "#{subdomain}.harvestapp.com", (ssl ? 443 : 80)
      request = method_class.new "/#{action}"
      https.use_ssl = ssl
      request.basic_auth login, password
      request.content_type = 'application/xml'
      request['Accept']    = 'application/xml'
      response = https.request request, data
      if response.kind_of? Net::HTTPSuccess
        response.body
      elsif response.kind_of? Net::HTTPFound
        raise Failure, "Redirected in the request. Perhaps your ssl configuration variable is set incorrectly?"
      else
        raise Failure, "Unexpected response from the upstream API"
      end
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
