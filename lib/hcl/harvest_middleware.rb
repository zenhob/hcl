require 'faraday'

class HCl::HarvestMiddleware < Faraday::Middleware
  Faraday.register_middleware harvest: ->{ self }
  MIME_TYPE = 'application/json'.freeze

  dependency do
    require 'yajl'
    require 'escape_utils'
  end

  def initialize app, user, password
    super app
    @auth = Faraday::Request::BasicAuthentication.new app, user, password
  end

  def call(env)
    # encode with and accept json
    env[:request_headers]['Accept'] = MIME_TYPE
    env[:request_headers]['Content-Type'] = MIME_TYPE
    env[:body] = Yajl::Encoder.encode(env[:body])

    #  basic authentication
    @auth.call(env)

    # response processing
    @app.call(env).on_complete do |env|
      case env[:status]
      when 200..299
        begin 
          env[:body] = deep_html_unescape(Yajl::Parser.parse(env[:body], symbolize_keys:true))
        rescue Yajl::ParseError
          env[:body]
        end
      when 300..399
        raise Failure, "Redirected! Perhaps your ssl configuration variable is set incorrectly?"
      when 400..499
        raise AuthFailure, "Login failed."
      when 503
       raise ThrottleFailure, env
      else
        raise Failure, "Unexpected response from the upstream API."
      end
    end
  end

  def deep_html_unescape obj
    if obj.kind_of? Hash
      obj.inject({}){|o,(k,v)| o.update(k => deep_html_unescape(v)) }
    elsif obj.kind_of? Array
      obj.inject([]){|o,v| o << deep_html_unescape(v) }
    else
      EscapeUtils.unescape_html(obj.to_s)
    end
  end

  class Failure < StandardError; end
  class AuthFailure < StandardError; end
  class ThrottleFailure < StandardError
    attr_reader :retry_after
    def initialize env
      @retry_after = env[:response_headers]['retry-after'].to_i
      super "Too many requests! Try again in #{@retry_after} seconds."
    end
  end
end
