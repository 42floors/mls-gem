# require 'test_helper'
#
# class TestResource < MLS::Resource
# end
#
# class MLS::ResourceTest < Minitest::Test
#
#   test "subclasses extend MLS::Model" do
#     assert TestResource.kind_of?(MLS::Model)
#   end
#
#   test ""
#
#   def test_instance_methods
#     resource = TestResource.new
#
#     assert resource.respond_to?(:new_record?)
#     assert resource.respond_to?(:persisted?)
#     assert resource.respond_to?(:save)
#
#     assert resource.respond_to?(:attributes)
#     assert resource.respond_to?(:set_default_values)
#     assert resource.respond_to?(:update_attributes)
#
#     assert resource.respond_to?(:to_hash)
#     assert resource.respond_to?(:to_key)
#   end
#
#   test 'save returns true || false'
#
# end