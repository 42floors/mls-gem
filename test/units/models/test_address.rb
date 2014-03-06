require 'test_helper'

class TestAddress < ::Test::Unit::TestCase

  def test_attributes
    address = MLSGem::Address.new

    attributes = [:id, :name, :slug, :latitude, :longitude, :formated_address, :streetnumber, :street, :neighbrhood, :city, :county, :state, :countr, :postalcode]

    attributes.each do |attribute|
      assert address.respond_to?(attribute), "address should respond to #{attribute}"
    end
  end

  def test_class_methods
    assert MLSGem::Address.respond_to?(:query)
    assert MLSGem::Address.respond_to?(:box_cluster)
  end

end
