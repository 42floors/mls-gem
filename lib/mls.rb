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
    belongs_to :avatar, :class_name => 'Photo'
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

    result += "#{options[:host]}/#{avatar_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end

require 'mls/photo'
require 'mls/account'
require 'mls/email'
require 'mls/organization'
require 'mls/property'
require 'mls/region'
require 'mls/listing'
require 'mls/space'
require 'mls/lead'
require 'mls/address'
require 'mls/locality'
require 'mls/flyer'
require 'mls/inquiry'
require 'mls/agency'
require 'mls/session'
require 'mls/floorplan'
require 'mls/use'
require 'mls/slug'
require 'mls/comment'
require 'mls/unit'
require 'mls/recommendation'

# Models
# # Helpers
# class MLS
#
#   def current_account
#   end
#
# end
