require 'test_helper'

class TestTour < ::Test::Unit::TestCase

  # def test_attributes
  #   tr = MLSGem::Tour.new
  # 
  #   assert tr.respond_to?(:message)
  # end
  # 
  # def test_attr_accessors
  #   tr = MLSGem::Tour.new
  # 
  #   assert tr.respond_to?(:listing)
  # end
  # 
  # def test_class_methods
  #   assert MLSGem::Tour.respond_to?(:get_all_for_account)
  #   assert MLSGem::Tour.respond_to?(:create)
  # end
  # 
  # def test_parser
  #   assert defined?(MLSGem::Tour::Parser)
  # end

  test 'it' do
    @account = FactoryGirl.create(:account)
    @listing = FactoryGirl.create(:listing)
  end
  
end
