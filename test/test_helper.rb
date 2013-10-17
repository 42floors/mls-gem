# require 'simplecov'
# SimpleCov.start do
#   add_filter "/test/"
#   use_merging true
# end

require 'mls'
require 'turn'
require 'faker'
require 'test/unit'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'../'))
require 'lib/mls/factories_helper'

CACHE = {}
MLS_HOST = ENV['MLS_URL'] || 'http://localhost:4000/api'

MLS.url = ENV["MLS_TEST_URL"] || 'http://LBJXFC%2BhDiRRCYj6kXtXREfgNXRCJa8ALvPn%2FIeyjSe2QsQyHZ%2F%2BWwN2VZM2cw%3D%3D@localhost:4000'#
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

def mock_response(method=:get, code='200', body='')
  FakeWeb.register_uri(method, "http://mls.test/test", :status => [code, "Filler"], :body => body)
  uri = URI.parse("http://mls.test/test")
  case method
  when :get
    Net::HTTP.get_response(uri)
  when :post
    Net::HTTP.post_form(uri)
  end
end
