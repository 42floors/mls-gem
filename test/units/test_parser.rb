require 'test_helper'

class MyParser < MLS::Parser; end

class TestParser < ::Test::Unit::TestCase

  def test_attr_readers
    parser = MyParser.new

    assert parser.respond_to?(:object)
  end

  def test_instance_methods
    parser = MyParser.new

    assert parser.respond_to?(:parse)
    assert parser.respond_to?(:update_attributes)
    assert parser.respond_to?(:extract_attributes)
  end

  def test_class_methods
    assert MyParser.respond_to?(:parse)
    assert MyParser.respond_to?(:parse_collection)
    assert MyParser.respond_to?(:build)
    assert MyParser.respond_to?(:update)
    assert MyParser.respond_to?(:extract_attributes)
    assert MyParser.respond_to?(:object_class)
    assert MyParser.respond_to?(:root_element)
    assert MyParser.respond_to?(:collection_root_element)
  end

end
