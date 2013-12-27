require 'hcl/harvest_middleware'
require 'faraday'

module HCl
  module Net
    class << self
      # configuration accessors
      CONFIG_VARS = [ :login, :password, :subdomain, :ssl ].freeze.
        each { |config_var| attr_reader config_var }

      def config_hash
        CONFIG_VARS.inject({}) {|c,k| c.update(k => send(k)) }
      end

      def configure opts
        @login = opts['login'].freeze
        @password = opts['password'].freeze
        @subdomain = opts['subdomain'].freeze
        @ssl = !!opts['ssl']
        @http = Faraday.new(
          "http#{ssl ? 's' : '' }://#{subdomain}.harvestapp.com"
        ) do |f|
          f.use :harvest, login, password
          f.adapter Faraday.default_adapter
        end
        self
      end

      def get action
        @http.get(action).body
      end

      def post action, data
        @http.post(action, data).body
      end

      def delete action
        @http.delete(action).body
      end
    end
  end
end
