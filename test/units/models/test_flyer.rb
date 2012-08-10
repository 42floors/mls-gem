require 'test_helper'

class TestFlyer < ::Test::Unit::TestCase


  def test_create_flyer
    flyer = MLS::Flyer.create(:file => File.new('test/fixtures/flyer.pdf'))
    assert flyer.id
  end
  
  def test_attach_flyer_to_listing
    listing = MLS::Listing.create
    flyer = MLS::Flyer.create(
      :file => File.new('test/fixtures/flyer.pdf'),
      :subject => listing)
    
    flyer = MLS::Flyer.find(flyer.id)
    assert_equal listing.id, flyer.subject_id
    assert_equal "Listing", flyer.subject_type
  end

end