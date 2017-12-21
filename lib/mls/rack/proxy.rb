require 'rack'
require 'rack/builder'

module MLS
  module Rack
    class Proxy
      
      def self.new
        app = super
        ::Rack::Builder.new do
          use(ActionDispatch::Cookies)
          use(ActionDispatch::Session::CookieStore, {
            key: Rails.application.config.session_options[:key],
            path: '/',
            secret: Rails.application.secrets[:secret_key_base]
          })
          run app
        end.to_app
      end
      
      def extract_http_request_headers(env)
        headers = env.reject do |k, v|
          !(/^HTTP_[A-Z_]+$/ === k) || v.nil?
        end.map do |k, v|
          [k.sub(/^HTTP_/, "").gsub("_", "-"), v]
        end.inject({}) do |hash, k_v|
          k, v = k_v
          hash[k] = v
          hash
        end
    
        headers.delete_if {|key, value| ["HOST", "API-VERSION", "CONNECTION", "VERSION"].include?(key) }
        x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")
    
        headers.merge!("X-Forwarded-For" =>  x_forwarded_for)
      end
  
      def call(env)
        request = Net::HTTP.const_get(env['REQUEST_METHOD'].capitalize).new(env['PATH_INFO'] + '?' + env['QUERY_STRING'])
        request.initialize_http_header(extract_http_request_headers(env))
    
        if request.request_body_permitted?
          if env['TRANSFER-ENCODING'] == 'chunked'
            request.body_stream = env['rack.input']
          elsif env['CONTENT_LENGTH']
            request.body = env['rack.input'].read
          end
        end
        request['Content-Type'] = env['CONTENT_TYPE']
    
        response = MLS::Model.connection_pool.with_connection do |conn|
          with_cookie_store(env) do
            request_uri = "http#{conn.instance_variable_get(:@connection).use_ssl ? 's' : ''}://#{conn.instance_variable_get(:@connection).host}#{conn.instance_variable_get(:@connection).port != 80 ? (conn.instance_variable_get(:@connection).port == 443 && conn.instance_variable_get(:@connection).use_ssl ? '' : ":#{conn.instance_variable_get(:@connection).port}") : ''}#{request.path}"
            request['Cookie'] = Thread.current[:sunstone_cookie_store].cookie_header_for(request_uri)
            conn.instance_variable_get(:@connection).send(:request_headers).each { |k, v| request[k] = v if ['Api-Version', 'Api-Key'].include?(k) }
        
            conn.instance_variable_get(:@connection).instance_variable_get(:@connection).request(request)
          end
        end
        response_headers = {}
        response.each_header { |k, v| response_headers[k] = v unless k == 'transfer-encoding' }
    
        [response.code, response_headers, [response.body]]
      end
  
      def with_cookie_store(env)
        store = CookieStore::HashStore.new
        store.add_from_json(env['rack.session']['cookie_store']) if env['rack.session']['cookie_store']
        Thread.current[:sunstone_cookie_store] = store
        result = yield
        Thread.current[:sunstone_cookie_store] = nil
        env['rack.session']['cookie_store'] = store.to_json
        result
      end
      
    end
  end
end