require 'hcl/harvest_middleware'
require 'faraday'

module HCl
  class Net
    # configuration accessors
    CONFIG_VARS = [ :login, :password, :subdomain ].freeze.
      each { |config_var| attr_reader config_var }

    def config_hash
      CONFIG_VARS.inject({}) {|c,k| c.update(k => send(k)) }
    end

    def initialize opts
      @login = opts['login'].freeze
      @password = opts['password'].freeze
      @subdomain = opts['subdomain'].freeze
      @http = Faraday.new(
        "https://#{subdomain}.harvestapp.com"
      ) do |f|
        f.use :harvest, login, password
        if opts['test_adapter']
          f.adapter :test, opts['test_adapter']
        else
          f.adapter Faraday.default_adapter
        end
      end
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
