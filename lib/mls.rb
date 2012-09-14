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
  def url=(uri) # TODO: testme
    @url = URI.parse(uri)
    @api_key = CGI.unescape(@url.user)
    @host, @port = @url.host, @url.port
  end

  def logger # TODO: testme
    @logger ||= default_logger
  end

  # Returns the current connection to the MLS or if connection has been made
  # it returns a new connection
  def connection # TODO: testme
    @connection ||= Net::HTTP.new(@host, @port)
  end

  # provides the asset host, if asset_host is set then it is returned,
  # otherwise it queries the MLS for this configuration.
  def asset_host # TODO: testme
    @asset_host ||= get('/asset_host').body
  end

  def headers # TODO: testme
    h = {
      'Content-Type' => 'application/json',
      'X-42Floors-API-Version' => API_VERSION,
      'X-42Floors-API-Key' => api_key
    }
    h['X-42Floors-API-Auth-Key'] = auth_key if auth_key
    h
  end
  
  def add_headers(req) # TODO: testme
    headers.each { |k, v| req[k] = v }
  end
  
  def put(url, body={}) # TODO: testme
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
  
  # Post to +url+ on the MLS Server. Automatically includes any headers returned
  # by the MLS#headers function.
  #
  # Paramaters::
  #
  # * +url+ - The +url+ on the server to Post to. This url will automatically
  #   be prefixed with <tt>"/api"</tt>. So to post to <tt>"/api/account"</tt>
  #   you only need to pass <tt>"/accounts"</tt> as +url+
  # * +body+ - A Ruby object which is converted into JSON and added in the POST
  #   Body.
  # * +valid_response_codes+ - An Array of HTTP response codes that should be
  #   considered accepable and not raise exceptions. For example If you don't
  #   want a MLS::Exception::NotFound to be raised when a POST request returns
  #   a 404 pass in 404, and the response body will be returned if the status
  #   code is a 404 as it does if the status code is in the 200..299 rage. Status
  #   codes in the 200..299 range are *always* considred acceptable
  #
  # Return Value::
  #
  #  Returns the return value of the <tt>&block</tt> if given, otherwise the response
  #  object
  #
  # Examples:
  #
  #  #!ruby
  #  MLS.post('/example') # => #<Net::HTTP::Response>
  #
  #  MLS.post('/example', {:body => 'stuff'}) # => #<Net::HTTP::Response>
  #
  #  MLS.post('/404') # => raises MLS::Exception::NotFound
  #
  #  MLS.post('/404', nil, 404, 450..499) # => #<Net::HTTP::Response>
  #
  #  MLS.post('/404', nil, [404, 450..499]) # => #<Net::HTTP::Response>
  #
  #  MLS.post('/404', nil, 404) # => #<Net::HTTP::Response>
  #
  #  # this will still raise an exception if the response_code is not valid
  #  MLS.post('/act') do |response, response_code|
  #    # ...
  #  end
  def post(url, body={}, *valid_response_codes, &block) # TODO: testme
    body ||= {}
    
    req = Net::HTTP::Post.new("/api#{url}")
    req.body = Yajl::Encoder.encode(body)
    add_headers(req)
    
    response = connection.request(req)
    handle_response(response, valid_response_codes)

    if block_given?
      yield(response, response.code.to_i)
    else
      response
    end
  end

  def delete(url, body={}) # TODO: testme
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

  def get(url, params={}) # TODO: testme
    url = "/api#{url}?" + params.to_param
    req = Net::HTTP::Get.new(url)
    add_headers(req)
    response = connection.request(req)
    if block_given?
      yield(response.code.to_i, response)
    else
      handle_response(response)
    end
  end

  # Raise an MLS::Exception based on the response_code, unless the response_code
  # is include in the valid_response_codes Array
  #
  # Paramaters::
  #
  # * +response+ - The Net::HTTP::Response object
  # * +valid_response_codes+ - An Array, Integer, or Range. If it's Array the
  #   Array can include both Integers or Ranges.
  #
  # Return Value::
  #
  #  If an exception is not raised the +response+ is returned
  #
  # Examples:
  #
  #  #!ruby
  #  MLS.handle_response(<Net::HTTP::Response @code=200>) # => <Net::HTTP::Response @code=200>
  #  
  #  MLS.handle_response(<Net::HTTP::Response @code=404>) # => raises MLS::Exception::NotFound
  #  
  #  MLS.handle_response(<Net::HTTP::Response @code=500>) # => raises MLS::Exception
  #  
  #  MLS.handle_response(<Net::HTTP::Response @code=404>, 404) # => <Net::HTTP::Response @code=404>
  #  
  #  MLS.handle_response(<Net::HTTP::Response @code=500>, 404, 500) # => <Net::HTTP::Response @code=500>
  #
  #  MLS.handle_response(<Net::HTTP::Response @code=405>, 300, 400..499) # => <Net::HTTP::Response @code=405>
  #
  #  MLS.handle_response(<Net::HTTP::Response @code=405>, [300, 400..499]) # => <Net::HTTP::Response @code=405>
  def handle_response(response, *valid_response_codes)
    if response['X-42Floors-API-Version-Deprecated']
      logger.warn("DEPRECATION WARNING: API v#{API_VERSION} is being phased out")
    end
    
    code = response.code.to_i
    valid_response_codes.flatten!
    valid_response_codes << (200..299)
    
    if !valid_response_codes.detect{|i| i.is_a?(Range) ? i.include?(code) : i == code}
      case code
      when 400
        raise MLS::Exception::BadRequest, response.body
      when 401
        raise MLS::Exception::Unauthorized, response.body
      when 404, 410
        raise MLS::Exception::NotFound
      when 422
        raise MLS::Exception::ApiVersionUnsupported, response.body
      when 503
        raise MLS::Exception::ServiceUnavailable, response.body
      when 300..599
        raise MLS::Exception, code
      end
    end
    
    response
  end
  
  # Ping the MLS. If everything is configured and operating correctly <tt>"pong"</tt>
  # will be returned. Otherwise and MLS::Exception should be thrown.
  #
  #  #!ruby
  #  MLS.ping # => "pong"
  #    
  #  MLS.ping # raises MLS::Exception::ServiceUnavailable if a 503 is returned
  def ping # TODO: testme
    get('/ping').body
  end

  def auth_ping # TODO: testme
    post('/ping').body
  end

  def default_logger # TODO: testme
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger
  end

  # Delegates all uncauge class method calls to the singleton
  def self.method_missing(method, *args, &block) #:nodoc:  # TODO: testme
    instance.__send__(method, *args, &block)
  end
  
  def self.parse(json) # TODO: testme
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
