require 'test_helper'

class TestAddress < ::Test::Unit::TestCase

  def test_attributes
    address = MLS::Address.new

    attributes = [:id, :name, :slug, :latitude, :longitude, :formated_address, :streetnumber, :street, :neighbrhood, :city, :county, :state, :countr, :postalcode]

    attributes.each do |attribute|
      assert address.respond_to?(attribute), "address should respond to #{attribute}"
    end
  end

  def test_class_methods
    assert MLS::Address.respond_to?(:query)
    assert MLS::Address.respond_to?(:box_cluster)
  end

end
