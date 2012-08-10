# require 'simplecov'
# SimpleCov.start do
#   add_filter "/test/"
#   use_merging true
# end

require 'mls'
require 'turn'
require 'faker'
require 'test/unit'
require 'factory_girl'

FactoryGirl.find_definitions

MLS.url = ENV["MLS_TEST_URL"]
MLS.auth_key = MLS::Account.authenticate(ENV["MLS_USER"], ENV["MLS_PASSWORD"]).auth_key

