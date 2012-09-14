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
require 'fakeweb'

CACHE = {}
FactoryGirl.find_definitions

MLS.url = 'http://LBJXFC%2BhDiRRCYj6kXtXREfgNXRCJa8ALvPn%2FIeyjSe2QsQyHZ%2F%2BWwN2VZM2cw%3D%3D@localhost:4000'#ENV["MLS_TEST_URL"]
# MLS.auth_key = MLS::Account.authenticate('jonbracy@gmail.com', 'test').auth_key

# File 'lib/active_support/testing/declarative.rb', somewhere in rails....
class ::Test::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end