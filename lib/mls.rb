require 'uri'
require 'cgi'
require 'logger'
require 'net/https'
require 'singleton'
require 'yajl'
require 'bigdecimal'
require 'bigdecimal/util'
require 'active_support/core_ext'
require 'date'
require 'time'

class Decimal #:nodoc:
end

class Boolean #:nodoc:
end

# _MLS_ is a low-level API. It provides basic HTTP #get, #post, #put, and #delete
# calls to the MLS. It can also provides basic error checking of responses.
class MLS
  include Singleton

  API_VERSION = '0.1.0'

  attr_reader :url
  attr_writer :asset_host
  attr_accessor :api_key, :auth_key, :logger

  # Sets the API Token and Host of the MLS Server
  #
  #  #!ruby
  #  MLS.url = "https://mls.42floors.com/API_KEY"
  def url=(uri)
    @url = URI.parse(uri)
    @api_key = CGI.unescape(@url.user)
    @host, @port = @url.host, @url.port
  end

  def logger
    @logger ||= default_logger
  end

  # Returns the current connection to the MLS or if connection has been made
  # it returns a new connection
  def connection
    @connection ||= Net::HTTP.new(@host, @port)
  end

  # provides the asset host, if asset_host is set then it is returned,
  # otherwise it queries the MLS for this configuration.
  def asset_host
    @asset_host ||= get('/asset_host').body
  end

  def headers
    h = {
      'Content-Type' => 'application/json',
      'X-42Floors-API-Version' => API_VERSION,
      'X-42Floors-API-Key' => api_key
    }
    h['X-42Floors-API-Auth-Key'] = auth_key if auth_key
    h
  end
  
  def add_headers(req)
    headers.each { |k, v| req[k] = v }
  end
  
  def put(url, body={})
    req = Net::HTTP::Put.new("/api#{url}")
    req.body = Yajl::Encoder.encode(body)
    add_headers(req)
    
    response = connection.request(req)
    if block_given?
      yield(response.code.to_i, response)
    else
      handle_response(response)
    end
  end

  def post(url, body={})
    req = Net::HTTP::Post.new("/api#{url}")
    req.body = Yajl::Encoder.encode(body)
    add_headers(req)
    
    response = connection.request(req)
    if block_given?
      yield(response.code.to_i, response)
    else
      handle_response(response)
    end
  end

  def delete(url, body={})
    req = Net::HTTP::Delete.new("/api#{url}")
    req.body = Yajl::Encoder.encode(body)
    add_headers(req)
    
    response = connection.request(req)
    if block_given?
      yield(response.code.to_i, response)
    else
      handle_response(response)
    end
  end

  def get(url, params={})
    url = "/api#{url}?" + params.to_param
    req = Net::HTTP::Get.new(url)
    add_headers(req)
    response = connection.request(req)
    if block_given?
      yield(response.code.to_i, response)
    else
      handle_response(response)
    end
    
    response
  end

  def handle_response(response)
    if response['X-42Floors-API-Version-Deprecated']
      logger.warn("DEPRECATION WARNING: API v#{API_VERSION} is being phased out")
    end
    
    raise(response.code, response.body)
    response.body
  end
  
  def raise(error_code, message=nil)
    case error_code.to_i
    when 401
      super MLS::Exception::Unauthorized, message
    when 404, 410
      super MLS::Exception::NotFound, message
    when 422
      super MLS::Exception::ApiVersionUnsupported, message
    when 503
      super MLS::Exception::ServiceUnavailable, message
    when 300...400
      super MLS::Exception, error_code
    when 400
      super MLS::Exception::BadRequest, message
    when 401...500
      super MLS::Exception, error_code
    when 500...600
      super MLS::Exception, error_code
    end
  end

  # Ping the MLS. If everything is configured and operating correctly <tt>"pong"</tt>
  # will be returned. Otherwise and MLS::Exception should be thrown.
  #
  #  #!ruby
  #  MLS.ping # => "pong"
  #    
  #  MLS.ping # raises MLS::Exception::ServiceUnavailable if a 503 is returned
  def ping
    get('/ping').body
  end

  def auth_ping
    post('/ping').body
  end

  def default_logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger
  end

  # Delegates all uncauge class method calls to the singleton
  def self.method_missing(method, *args, &block) #:nodoc:
    instance.__send__(method, *args, &block)
  end
  
  def self.parse(json)
    Yajl::Parser.new(:symbolize_keys => true).parse(json)
  end

end

require 'mls/errors'
require 'mls/resource'
require 'mls/parser'

# Properties
require 'mls/property'
require 'mls/properties/fixnum'
require 'mls/properties/boolean'
require 'mls/properties/decimal'
require 'mls/properties/datetime'
require 'mls/properties/string'

# Models
require 'mls/model'
require 'mls/models/account'
require 'mls/models/listing'
require 'mls/models/address'
require 'mls/models/photo'
require 'mls/models/tour_request'
require 'mls/models/flyer'
