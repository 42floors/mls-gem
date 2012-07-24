require 'test_helper'

class TestListing < ::Test::Unit::TestCase

  def test_properties
    listing = MLS::Listing.new

    assert listing.respond_to?(:id)
    assert listing.respond_to?(:address_id)
    assert listing.respond_to?(:use_id)
    assert listing.respond_to?(:use)
    assert listing.respond_to?(:account_id)
    assert listing.respond_to?(:hidden)
    assert listing.respond_to?(:name)
    assert listing.respond_to?(:kind)
    assert listing.respond_to?(:space_type)
    assert listing.respond_to?(:unit)
    assert listing.respond_to?(:floor)
    assert listing.respond_to?(:comments)
    assert listing.respond_to?(:total_size)
    assert listing.respond_to?(:maximum_contiguous_size)
    assert listing.respond_to?(:minimum_divisable_size)
    assert listing.respond_to?(:lease_type)
    assert listing.respond_to?(:rate)
    assert listing.respond_to?(:rate_units)
    assert listing.respond_to?(:rate_per_month)
    assert listing.respond_to?(:rate_per_year)
    assert listing.respond_to?(:tenant_improvements)
    assert listing.respond_to?(:nnn_expenses)
    assert listing.respond_to?(:sublease_expiration)
    assert listing.respond_to?(:available_on)
    assert listing.respond_to?(:maximum_term_length)
    assert listing.respond_to?(:minimum_term_length)
    assert listing.respond_to?(:offices)
    assert listing.respond_to?(:conference_rooms)
    assert listing.respond_to?(:bathrooms)
    assert listing.respond_to?(:desks)
    assert listing.respond_to?(:kitchen)
    assert listing.respond_to?(:showers)
    assert listing.respond_to?(:bike_rack)
    assert listing.respond_to?(:bikes_allowed)
    assert listing.respond_to?(:server_room)
    assert listing.respond_to?(:reception_area)
    assert listing.respond_to?(:turnkey)
    assert listing.respond_to?(:patio)
    assert listing.respond_to?(:copy_room)
    assert listing.respond_to?(:dog_friendly)
    assert listing.respond_to?(:cabling)
    assert listing.respond_to?(:ready_to_move_in)
    assert listing.respond_to?(:recent_space_improvements)
    assert listing.respond_to?(:printers)
    assert listing.respond_to?(:furniture_available)
    assert listing.respond_to?(:created_at)
    assert listing.respond_to?(:updated_at)
  end

  def test_attr_accessors
    listing = MLS::Listing.new

    assert listing.respond_to?(:address)
    assert listing.respond_to?(:agents)
  end

  def test_instance_methods
    listing = MLS::Listing.new

    assert listing.respond_to?(:photos)
  end

  def test_class_methods
    assert MLS::Listing.respond_to?(:find)
  end

end
