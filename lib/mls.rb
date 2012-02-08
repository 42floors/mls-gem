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

   end

   class Resource < ActiveResource::Base
      self.site      = MLS.site
      self.user      = nil
      self.password  = nil
   end

end


require 'mls/listing'
require 'mls/property'
