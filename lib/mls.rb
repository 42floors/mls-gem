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

class BigDecimal
  old_to_s = instance_method :to_s

  define_method :to_s do |param='F'|
    old_to_s.bind(self).(param)
  end
end

class Decimal
end
class Boolean
end

class MLS
  include Singleton

  API_VERSION = '0.1.0'

  attr_accessor :url, :api_key, :auth_key, :logger, :asset_host

  def url=(uri)
    @url = uri

    uri = URI.parse(uri)
    @api_key = CGI.unescape(uri.user)
    @host = uri.host
    @port = uri.port
  end

  def logger
    @logger ||= default_logger
  end

  def connection
    @connection ||= Net::HTTP.new(@host, @port)
  end

  def asset_host
    @asset_host ||= get('/asset_host').body
  end

  def add_headers(req)
    req['Content-Type'] = 'application/json'
    req['X-42Floors-API-Version'] = API_VERSION
    req['X-42Floors-API-Key'] = api_key
    req['X-42Floors-API-Auth-Key'] = auth_key if auth_key
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
      super Unauthorized, message
    when 404, 410
      super NotFound, message
    when 422
      super ApiVersionUnsupported, message
    when 300...400
      super MLS::Exception, error_code
    when 400
      super MLS::BadRequest, message
    when 401...500
      super MLS::Exception, error_code
    when 500...600
      super MLS::Exception, error_code
    end
  end

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

  def self.method_missing(method, *args, &block)
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
