require 'faraday_middleware'

module HCl
  module Net
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

    def self.configure opts = nil
      if opts
        self.login = opts['login']
        self.password = opts['password']
        self.subdomain = opts['subdomain']
        self.ssl = opts['ssl']
      end
    end

    def self.config_hash
      CONFIG_VARS.inject({}) {|c,k| c.update(k => send(k)) }
    end

    def self.faraday
      @faraday ||= Faraday.new(
        "http#{ssl && 's'}://#{subdomain}.harvestapp.com"
      ) do |f|
        f.headers['Accept'] = 'application/json'
        f.request :json
        f.request :basic_auth, login, password
        f.use HCl::HarvestMiddleware, content_type: /\bjson\b/
        f.adapter Faraday.default_adapter
      end
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
  end
end
