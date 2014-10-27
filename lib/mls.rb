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
  
end

class MLS::Model < ActiveRecord::Base
  self.abstract_class = true
end

module MLS::Slugger
  
  extend ActiveSupport::Concern
  
  module ClassMethods
  
    def find(*args)
      friendly = -> (arg) { arg.respond_to?(:to_i) && arg.to_i.to_s != arg.to_s }

      if args.count == 1 && friendly.call(args.first)
        find_by_slug!(args)
      else
        super
      end
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
      :protocol => "http",
      :bg => nil,
      :format => "jpg"
    });

    url_params = {s: options[:style], bg: options[:bg]}.select{ |k, v| v }
    result = "#{options[:protocol]}://#{MLS.image_host}/#{avatar_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end

require 'mls/photo'
require 'mls/account'
require 'mls/organization'
require 'mls/property'
require 'mls/region'
require 'mls/listing'
require 'mls/space'
require 'mls/lead'
require 'mls/lead_listing'
require 'mls/lead_property'
require 'mls/address'
require 'mls/locality'
require 'mls/flyer'
require 'mls/inquiry'
require 'mls/agency'
require 'mls/session'
require 'mls/floorplan'
require 'mls/use'

# Models
# # Helpers
# class MLS
#
#   def current_account
#   end
#
# end
