require 'test_helper'

class TestContact < ::Test::Unit::TestCase

  # def test_properties
  #   tr = MLS::Contact.new
  # 
  #   assert tr.respond_to?(:message)
  # end
  # 
  # def test_attr_accessors
  #   tr = MLS::Contact.new
  # 
  #   assert tr.respond_to?(:listing)
  # end
  # 
  # def test_class_methods
  #   assert MLS::Contact.respond_to?(:get_all_for_account)
  #   assert MLS::Contact.respond_to?(:create)
  # end
  # 
  # def test_parser
  #   assert defined?(MLS::Contact::Parser)
  # end

  test 'it' do
    @account = FactoryGirl.create(:account)
    @listing = FactoryGirl.create(:listing)
  end
  
end
