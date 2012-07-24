require 'test_helper'

class TestTourRequest < ::Test::Unit::TestCase

  def test_properties
    tr = MLS::TourRequest.new

    assert tr.respond_to?(:message)
  end

  def test_attr_accessors
    tr = MLS::TourRequest.new

    assert tr.respond_to?(:listing)
  end

  def test_class_methods
    assert MLS::TourRequest.respond_to?(:get_all_for_account)
    assert MLS::TourRequest.respond_to?(:create)
  end

  def test_parser
    assert defined?(MLS::TourRequest::Parser)
  end

end
