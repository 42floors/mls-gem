require 'test_helper'

class TestFlyer < ::Test::Unit::TestCase


  def test_create_flyer
    flyer = MLSGem::Flyer.create(:file => File.new('test/fixtures/flyer.pdf'))
    assert flyer.id
  end
  
  def test_attach_flyer_to_listing
    listing = MLSGem::Listing.create
    flyer = MLSGem::Flyer.create(
      :file => File.new('test/fixtures/flyer.pdf'),
      :subject => listing)
    
    flyer = MLSGem::Flyer.find(flyer.id)
    assert_equal listing.id, flyer.subject_id
    assert_equal "Listing", flyer.subject_type
  end

end