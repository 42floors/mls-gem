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
    MLS::Model.connection.server_config['asset_host']
  end

  def self.image_host
    MLS::Model.connection.server_config['image_host']
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
  
end

require 'mls/photo'
require 'mls/account'
require 'mls/brokerage'
require 'mls/property'
require 'mls/region'
require 'mls/listing'
require 'mls/lease'
require 'mls/sublease'
require 'mls/space'
require 'mls/sale'
require 'mls/coworking_space'
require 'mls/address'
require 'mls/locality'
require 'mls/flyer'
require 'mls/agency'
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