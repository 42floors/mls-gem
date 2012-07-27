require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  use_merging true
end

require 'test/unit'
require 'turn'
require 'mls'
