require 'faraday_middleware/response_middleware'
require 'yajl'

class HCl::YajlMiddleware < FaradayMiddleware::ResponseMiddleware
  define_parser do |body|
    Yajl::Parser.parse(body, symbolize_keys:true)
  end
end
