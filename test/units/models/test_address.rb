require 'test_helper'

class TestAddress < ::Test::Unit::TestCase

  def test_properties
    address = MLS::Address.new

    properties = [:id, :name, :slug, :latitude, :longitude, :formated_address, :streetnumber, :street, :neighbrhood, :city, :county, :state, :countr, :postalcode]

    properties.each do |property|
      assert address.respond_to?(property), "address should respond to #{property}"
    end
  end

  def test_class_methods
    assert MLS::Address.respond_to?(:query)
    assert MLS::Address.respond_to?(:box_cluster)
  end

end
