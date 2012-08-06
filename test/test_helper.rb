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

puts FactoryGirl.find_definitions

MLS.url = 'http://xSgYUhc1XckzB6glk598XGVDPnGtyLQKItKXgWfP5xcwwjD9XY7O9dWFjVblZA%3D%3D@mls.dev'