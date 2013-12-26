require 'faraday'

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

      def http
        @http ||= Faraday.new(
          "http#{ssl && 's'}://#{subdomain}.harvestapp.com"
        ) do |f|
          f.request :basic_auth, login, password
          f.use :harvest
          f.adapter Faraday.default_adapter
        end
      end

      def get action
        http.get(action).body
      end

      def post action, data
        http.post(action, data).body
      end

      def delete action
        http.delete(action).body
      end
    end
  end
end
