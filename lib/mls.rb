require 'sunstone'

module MLS

  API_VERSION = '0.1.0'

  def request_headers
    super
    super.merge({
      'Api-Version' => API_VERSION
    })
  end

  def self.asset_host
    config['asset_host']
  end

  def self.image_host
    config['image_host']
  end

  def self.config
    @config ||= MLS::Model.connection.server_config
  end

  # Set a cookie jar to use during request sent during the
  def self.with_cookie_store(store, &block)
    Thread.current[:sunstone_cookie_store] = store
    yield
  ensure
    Thread.current[:sunstone_cookie_store] = nil
  end

  def self.with_api_key(key, &block)
    Thread.current[:sunstone_api_key] = key
    yield
  ensure
    Thread.current[:sunstone_api_key] = nil
  end

end

class MLS::Model < ActiveRecord::Base
  self.abstract_class = true
end

module MLS::Slugger

  extend ActiveSupport::Concern

  module ClassMethods

    def find(*ids)
      friendly = -> (id) { id.respond_to?(:to_i) && id.to_i.to_s != id.to_s }
      return super if ids.size > 1 || !ids.all? { |x| friendly.call(x) }

      find_by_slug!(ids)
    end

  end

  def to_param
    slug
  end

end

module MLS::Avatar

  extend ActiveSupport::Concern

  included do
    belongs_to :avatar, :class_name => 'Image'
  end

  def avatar_url(options={})

    options.reverse_merge!({
      :style => nil,
      :bg => nil,
      :protocol => 'https',
      :format => "jpg",
      :host => MLS.image_host
    });

    url_params = { s: options[:style], bg: options[:bg] }.select{ |k, v| v }

    if options[:protocol] == :relative # Protocol Relative
      result = '//'
    else options[:protocol]
      result = "#{options[:protocol]}://"
    end

    result += "#{options[:host]}/#{avatar_hash_key}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'mls', '*.rb'), &method(:require))
