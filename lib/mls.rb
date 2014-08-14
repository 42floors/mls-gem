require 'sunstone'

require 'mls/photo'
require 'mls/account'
#require 'mls/listing'

module MLS

  API_VERSION = '0.1.0'

  def request_headers
    super
    super.merge({
      'Api-Version' => API_VERSION
    })
  end

  def asset_host
    config[:asset_host]
  end

  def image_host
    config[:image_host]
  end

  def self.use_relative_model_naming?
    true
  end
end

Sunstone.extend(MLS)

Sunstone.site = 'http://1fc131b2294849e24514d788d6ae41a5@127.0.0.1:4000'

require 'mls/schema'
# Attributes
# require 'mls/attributes/hash'



# Models
# # Helpers
# class MLS
#
#   def current_account
#   end
#
# end

# def update
#   raise "cannot update account without id" unless id
#   MLS.put("/accounts/#{id}", { :account => to_hash}, 400) do |response, code|
#     MLS::Account::Parser.update(self, response.body)
#     code == 200
#   end
# end
#
# # Save the Account to the MLS. @errors will be set on the account if there
# # are any errors. @persisted will also be set to +true+ if the Account was
# # succesfully created
# def create
#   MLS.post('/accounts', {:account => to_hash}, 400) do |response, code|
#     raise MLS::Exception::UnexpectedResponse if ![201, 400].include?(code)
#     MLS::Account::Parser.update(self, response.body)
#     @persisted = true
#     code == 201
#   end
# end
#

#
# X-42Floors-Count
# X-42Floors-Page
# X-42Floors-Per-Page
# X-42Floors-Total-Pages
# X-42Floors-Total-Count
#
#
# X-42Floors-Page
# X-42Floors-Per-Page