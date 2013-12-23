require 'net/http'
require 'net/https'
require 'cgi'
require 'faraday_middleware'

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

    def get action
      new self.class.get(action).body
    end
    def post action, data
      new self.class.post(action, data).body
    end
    def delete action
      new self.class.delete(action).body
    end

    def self.faraday
      @faraday ||= Faraday.new(
        "http#{ssl && 's'}://#{subdomain}.harvestapp.com"
      ) do |f|
        f.headers['Accept'] = 'application/json'
        f.request :json
        f.request :basic_auth, login, password
        f.use HCl::YajlMiddleware, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end

    def initialize params
      @data = params
    end

    def self.get action
      faraday.get(action).body
    end

    def self.post action, data
      faraday.post(action, data).body
    end

    def self.delete action
      faraday.delete(action).body
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
  end
end
