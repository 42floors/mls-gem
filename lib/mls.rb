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
    MLS::Model.connection.server_config[:asset_host]
  end

  def self.image_host
    MLS::Model.connection.server_config[:image_host]
  end
  
end

class MLS::Model < ActiveRecord::Base
  self.abstract_class = true
end

require 'mls/photo'
require 'mls/account'
require 'mls/brokerage'
require 'mls/property'
require 'mls/region'
require 'mls/listing'
require 'mls/lease'
require 'mls/sublease'
require 'mls/coworking_space'
require 'mls/address'

# Models
# # Helpers
# class MLS
#
#   def current_account
#   end
#
# end