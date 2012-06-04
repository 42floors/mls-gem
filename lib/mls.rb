require 'mls/version'
require 'active_resource'

module MLS

  class << self

    attr_accessor :environment

    def env
      @environment ||= 'development'
    end

    def site
      env == 'production' ? 'http://mls.42floors.com' : 'http://staging.mls.42floors.com'
    end

    def asset_host=(host)
      @asset_host = host
    end

    def asset_host
      return @asset_host if @asset_host
      env == 'production' ? 'assets.42floors.com' : 's3.amazonaws.com/staging-assets.42floors.com'
    end

  end

  class Resource < ActiveResource::Base
    self.site      = MLS.site
    self.prefix    = '/api/'
    self.user      = nil
    self.password  = nil

    def create
      json = JSON.generate({self.class.element_name => JSON.parse(encode)})
      connection.post(collection_path, json, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end

    private

    def self.instantiate_collection(collection, prefix_options = {})
      collection[self.collection_name].collect! do |record|
        instantiate_record(record, prefix_options)
      end
    end
    
  end

end

require 'mls/use'
require 'mls/photo'
require 'mls/address'
require 'mls/listing'
