require 'faraday_middleware/response_middleware'
require 'multi_json'
require 'escape_utils'

class HCl::HarvestMiddleware < FaradayMiddleware::ResponseMiddleware
  class Failure < StandardError; end
  class AuthFailure < StandardError; end
  class ThrottleFailure < StandardError
    attr_reader :retry_after
    def initialize env
      @retry_after = env[:response_headers]['retry-after'].to_i
      super "Too many requests! Try again in #{@retry_after} seconds."
    end
  end

  def call(env)
    @app.call(env).on_complete do |env|
      case env[:status]
      when 200..299
        begin 
          env[:body] = unescape(MultiJson.load(env[:body], symbolize_keys:true))
        rescue MultiJson::LoadError
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

  def unescape obj
    if obj.kind_of? Hash
      obj.inject({}){|o,(k,v)| o[k] = unescape(v);o}
    elsif obj.kind_of? Array
      obj.inject([]){|o,v| o << unescape(v);o}
    else
      EscapeUtils.unescape_html(obj.to_s)
    end
  end

end
