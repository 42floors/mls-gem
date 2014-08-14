require 'test_helper'

class MLS::AttributeTest < Minitest::Test

  test "::new(NAME) sets @name to NAME" do
    attribute = MLS::Attribute.new("name")
    assert_equal "name", attribute.name
  end

  test "::new(NAME) sets @options to defaults" do
    attribute = MLS::Attribute.new("name")
    assert_equal MLS::Attribute::DEFAULT_OPTIONS, attribute.options
  end

  test "::new(NAME) sets @instance_variable_name" do
    attribute = MLS::Attribute.new("name")
    assert_equal "@name", attribute.instance_variable_name
  end


  test "::new(NAME) sets @default to nil" do
    attribute = MLS::Attribute.new("name")
    assert_equal nil, attribute.default
  end

  test "::new(NAME, :default => N) sets @default to N" do
    attribute = MLS::Attribute.new("name", :default => 'N')
    assert_equal 'N', attribute.default
  end

  test "::new(NAME) sets @reader_visibility to :public" do
    attribute = MLS::Attribute.new("name")
    assert_equal :public, attribute.reader_visibility
  end

  test "::new(NAME, :reader => :private) sets @reader_visibility to :private" do
    attribute = MLS::Attribute.new("name", :reader => :private)
    assert_equal :private, attribute.reader_visibility
  end

  test "::new(NAME) sets @writer_visibility to :public" do
    attribute = MLS::Attribute.new("name")
    assert_equal :public, attribute.writer_visibility
  end

  test "::new(NAME, :writer => :private) sets @writer_visibility to :private" do
    attribute = MLS::Attribute.new("name", :writer => :private)
    assert_equal :private, attribute.writer_visibility
  end

  test "::demodulized_names caches hash" do
    assert_equal MLS::Attribute.demodulized_names.object_id, MLS::Attribute.demodulized_names.object_id
  end

end