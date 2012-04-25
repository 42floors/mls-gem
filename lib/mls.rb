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
      self.user      = nil
      self.password  = nil
   end

end

require 'mls/use'
require 'mls/address'
require 'mls/listing'
require 'mls/property'
