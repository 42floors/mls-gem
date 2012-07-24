require 'test_helper'

class TestProperty < ::Test::Unit::TestCase

  def test_DEFAULT_OPTIONS
    assert_equal :always, MLS::Property::DEFAULT_OPTIONS[:serialize]
  end

  def test_attr_readers
    property = MLS::Property.new(:name => "blah")

    assert property.respond_to?(:model)
    assert property.respond_to?(:name)
    assert property.respond_to?(:instance_variable_name)
    assert property.respond_to?(:options)
    assert property.respond_to?(:default)
    assert property.respond_to?(:reader_visibility)
    assert property.respond_to?(:writer_visibility)
  end

  def test_instance_methods
    property = MLS::Property.new(:name => "blah")

    assert property.respond_to?(:set_default_value)
    assert property.respond_to?(:determine_visibility)
  end

  def test_class_methods
    assert MLS::Property.respond_to?(:determine_class)
    assert MLS::Property.respond_to?(:inherited)
    assert MLS::Property.respond_to?(:demodulized_names)
    assert MLS::Property.respond_to?(:find_class)
  end

end
