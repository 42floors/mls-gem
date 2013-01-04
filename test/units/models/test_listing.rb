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
    assert listing.respond_to?(:lease_terms)
    assert listing.respond_to?(:rate)
    assert listing.respond_to?(:rate_units)
    assert listing.respond_to?(:rate_per_month)
    assert listing.respond_to?(:rate_per_year)
    assert listing.respond_to?(:sublease_expiration)
    assert listing.respond_to?(:available_on)
    assert listing.respond_to?(:maximum_term_length)
    assert listing.respond_to?(:minimum_term_length)
    assert listing.respond_to?(:offices)
    assert listing.respond_to?(:conference_rooms)
    assert listing.respond_to?(:bathrooms)
    assert listing.respond_to?(:kitchen)
    assert listing.respond_to?(:showers)
    assert listing.respond_to?(:bikes_allowed)
    assert listing.respond_to?(:reception_area)
    assert listing.respond_to?(:patio)
    assert listing.respond_to?(:dog_friendly)
    assert listing.respond_to?(:ready_to_move_in)
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
  
  test '#request_tour for email without an account' do
    @listing = FactoryGirl.create(:listing)
    @name = Faker::Name.name
    @email = Faker::Internet.email
    tr = @listing.request_tour(@name, @email)


    assert_equal({}, tr.errors)
    assert_equal({}, tr.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr.id
  end
  
  test '#request_tour for email on a ghost account' do
    @account = FactoryGirl.create(:ghost_account)
    @listing = FactoryGirl.create(:listing)
    
    tr = @listing.request_tour(@account.name, @account.email)
    assert_equal({}, tr.errors)
    assert_equal({}, tr.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr.id
  end
  
  test '#request_tour for email on an account' do
    @account = FactoryGirl.create(:account)
    @listing = FactoryGirl.create(:listing)

    tr = @listing.request_tour(@account.name, @account.email)
    assert_equal({}, tr.errors)
    assert_equal({}, tr.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr.id
  end
  
  test '#request_tour for an non-existant listing' do
    @listing = FactoryGirl.build(:listing, :id => 94332)
    
    assert_raises(MLS::Exception::NotFound) do
      @listing.request_tour(Faker::Name.name, Faker::Internet.email)
    end
  end
  
  test '#request_tour without and account name' do
    @listing = FactoryGirl.create(:listing)
    
    tr = @listing.request_tour('', Faker::Internet.email)
    assert !tr.id
    assert_equal({:name => ["can't be blank"]}, tr.account.errors)
    
    tr = @listing.request_tour(nil, Faker::Internet.email)
    assert !tr.id
    assert_equal({:name => ["can't be blank"]}, tr.account.errors)
  end
  
  test '#request_tour without an account email' do
    @listing = FactoryGirl.create(:listing)
    
    tr = @listing.request_tour(Faker::Name.name, '')
    assert !tr.id
    assert_equal({:email => ["can't be blank", "is invalid"]}, tr.account.errors)
    
    tr = @listing.request_tour(Faker::Name.name, nil)
    assert !tr.id
    # assert !tr.persisted? #TODO move to persisted being based of id?
    assert_equal({:email => ["can't be blank", "is invalid"]}, tr.account.errors)
  end
  
  test '#request_tour with an account email' do
    @account = FactoryGirl.create(:account)
    @listing = FactoryGirl.create(:listing)
    
    tr = @listing.request_tour('', @account.email) # TODO should this try to set the name of the account?
    assert_equal({}, tr.errors)
    assert_equal({}, tr.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr.id
    assert tr.persisted?
  end
  
  test '#request_tour multiple times for a listing' do
    @account = FactoryGirl.create(:account)
    @listing = FactoryGirl.create(:listing)
    
    tr1 = @listing.request_tour(@account.name, @account.email)
    assert_equal({}, tr1.errors) # TODO should errors be here for account?
    assert_equal({}, tr1.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr1.persisted?
      
    tr2 = @listing.request_tour(@account.name, @account.email)
    assert_equal({}, tr2.errors)
    assert_equal({}, tr2.account.errors)
    # TODO assert_equal({}, tr.listing.errors)
    assert tr2.persisted?
    
    assert_not_equal tr1.id, tr2.id
  end
  
  test '#request_tour with optional info' do
    @listing = FactoryGirl.create(:listing)
    
    info = {:company => '42Floors', :population => 10, :funding => 'string thing', :move_in_date => '2012-09-12'}
    tr = @listing.request_tour(Faker::Name.name, Faker::Internet.email, info)

    assert tr.id
    assert_equal '42Floors', info[:company]
    assert_equal 10, info[:population]
    assert_equal 'string thing', info[:funding]
    assert_equal '2012-09-12', info[:move_in_date]
    
    tr = @listing.request_tour('', nil, info)
    assert !tr.id
    assert_equal '42Floors', info[:company]
    assert_equal 10, info[:population]
    assert_equal 'string thing', info[:funding]
    assert_equal '2012-09-12', info[:move_in_date]
  end

end
