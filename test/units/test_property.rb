require 'test_helper'

class TestAttribute < ::Test::Unit::TestCase

  def test_DEFAULT_OPTIONS
    assert_equal :always, MLSGem::Attribute::DEFAULT_OPTIONS[:serialize]
  end

  def test_attr_readers
    attribute = MLSGem::Attribute.new(:name => "blah")

    assert attribute.respond_to?(:model)
    assert attribute.respond_to?(:name)
    assert attribute.respond_to?(:instance_variable_name)
    assert attribute.respond_to?(:options)
    assert attribute.respond_to?(:default)
    assert attribute.respond_to?(:reader_visibility)
    assert attribute.respond_to?(:writer_visibility)
  end

  def test_instance_methods
    attribute = MLSGem::Attribute.new(:name => "blah")

    assert attribute.respond_to?(:set_default_value)
    assert attribute.respond_to?(:determine_visibility)
  end

  def test_class_methods
    assert MLSGem::Attribute.respond_to?(:determine_class)
    assert MLSGem::Attribute.respond_to?(:inherited)
    assert MLSGem::Attribute.respond_to?(:demodulized_names)
    assert MLSGem::Attribute.respond_to?(:find_class)
  end

end
