require 'faraday_middleware/response_middleware'
require 'yajl'
require 'cgi'

class HCl::YajlMiddleware < FaradayMiddleware::ResponseMiddleware
  def self.unescape obj
    if obj.kind_of? Hash
      obj.inject({}){|o,(k,v)| o[k] = unescape(v);o}
    elsif obj.kind_of? Array
      obj.inject([]){|o,v| o << unescape(v);o}
    else
      CGI.unescape_html(obj.to_s)
    end
  end

  define_parser do |body|
    unescape Yajl::Parser.parse(body, symbolize_keys:true)
  end
end
