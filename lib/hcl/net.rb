require 'faraday_middleware'

module HCl
  module Net
    class << self
      # configuration accessors
      CONFIG_VARS = [ :login, :password, :subdomain, :ssl ].freeze
      CONFIG_VARS.each { |config_var| attr_accessor config_var }

      def config_hash
        CONFIG_VARS.inject({}) {|c,k| c.update(k => send(k)) }
      end

      def configure opts = nil
        if opts
          self.login = opts['login']
          self.password = opts['password']
          self.subdomain = opts['subdomain']
          self.ssl = opts['ssl']
        end
      end

      def faraday
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

      def get action
        faraday.get(action).body
      end

      def post action, data
        faraday.post(action, data).body
      end

      def delete action
        faraday.delete(action).body
      end
    end
  end
end
