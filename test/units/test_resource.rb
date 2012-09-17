require 'test_helper'

class MyResource < MLS::Resource; end

class TestResource < ::Test::Unit::TestCase

  def test_attr_readers
    resource = MyResource.new

    assert resource.respond_to?(:errors)
    assert resource.respond_to?(:persisted)
  end

  def test_instance_methods
    resource = MyResource.new

    assert resource.respond_to?(:new_record?)
    assert resource.respond_to?(:persisted?)
    assert resource.respond_to?(:save)

    assert resource.respond_to?(:properties)
    assert resource.respond_to?(:set_default_values)
    assert resource.respond_to?(:update_attributes)

    assert resource.respond_to?(:to_hash)
    assert resource.respond_to?(:to_key)
  end

  test 'save returns true || false'
end
