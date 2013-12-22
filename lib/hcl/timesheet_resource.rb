require 'net/http'
require 'net/https'
require 'cgi'

module HCl
  class TimesheetResource
    class Failure < StandardError; end
    class AuthFailure < StandardError; end
    class ThrottleFailure < StandardError
      attr_reader :retry_after
      def initialize response
        @retry_after = response.headers['Retry-After'].to_i
        super "Too many requests! Try again in #{@retry_after} seconds."
      end
    end

    def self.configure opts = nil
      if opts
        self.login = opts['login']
        self.password = opts['password']
        self.subdomain = opts['subdomain']
        self.ssl = opts['ssl']
      end
    end

    # configuration accessors
    CONFIG_VARS = [ :login, :password, :subdomain, :ssl ].freeze
    CONFIG_VARS.each do |config_var|
      class_eval <<-EOC
        def self.#{config_var}= arg
          @@#{config_var} = arg
        end
        def self.#{config_var}
          @@#{config_var}
        end
      EOC
    end

    # @return [Hash]
    def self.config_hash
      CONFIG_VARS.inject({}) {|c,k| c.update(k => TimesheetResource.send(k)) }
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

    def self.connect
      Net::HTTP.new("#{subdomain}.harvestapp.com", (ssl ? 443 : 80)).tap do |https|
        https.use_ssl = ssl
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE if ssl
      end
    end

    def self.http_do method_class, action, data = nil
      https = connect
      request = method_class.new "/#{action}"
      request.basic_auth login, password
      request.content_type = 'application/xml'
      request['Accept']    = 'application/xml'
      response = https.request request, data
      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPFound
        raise Failure, "Redirected! Perhaps your ssl configuration variable is set incorrectly?"
      when Net::HTTPServiceUnavailable
        raise ThrottleFailure, response
      when Net::HTTPUnauthorized
        raise AuthFailure, "Login failed."
      else
        raise Failure, "Unexpected response from the upstream API."
      end
    end

    def id
      @data[:id]
    end

    def method_missing method, *args
      @data.key?(method.to_sym) ? @data[method] : super
    end

    def respond_to? method
      (@data && @data.key?(method.to_sym)) || super
    end

    def self.xml_to_hash elem
      elem.elements.map { |e| e.name }.inject({}) do |a, f|
        a[f.to_sym] = CGI.unescape_html(elem.elements[f].text || '') if elem.elements[f]
        a
      end
    end
  end
end
