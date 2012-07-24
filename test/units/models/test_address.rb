require 'test_helper'

class TestAddress < ::Test::Unit::TestCase

  def test_properties
    address = MLS::Address.new

    assert address.respond_to?(:id)
    assert address.respond_to?(:name)
    assert address.respond_to?(:slug)
    assert address.respond_to?(:latitude)
    assert address.respond_to?(:longitude)
    assert address.respond_to?(:formatted_address)
    assert address.respond_to?(:street_number)
    assert address.respond_to?(:street)
    assert address.respond_to?(:neighborhood)
    assert address.respond_to?(:city)
    assert address.respond_to?(:county)
    assert address.respond_to?(:state)
    assert address.respond_to?(:country)
    assert address.respond_to?(:postal_code)
  end

  def test_class_methods
    assert MLS::Address.respond_to?(:query)
    assert MLS::Address.respond_to?(:box_cluster)
  end

end
