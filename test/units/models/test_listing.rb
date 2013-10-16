require 'test_helper'

class TestListing < ::Test::Unit::TestCase

  def test_properties
    listing = MLS::Listing.new

    attributes = [:id, :address_id, :use, :account_id, :hidden, :name, :type, :space_type, :unit, :floor, :description, :size, :maximum_contiguous_size, :minimum_divisible_size, :lease_terms, :rate, :rate_units, :sublease_expiration, :available_on, :term, :offices, :conference_rooms, :bathrooms, :kitchen, :showers, :bikes_allowed, :reception_area, :patio, :dog_friendly, :ready_to_move_in, :furniture_available, :created_at, :updated_at]

    attributes.each do |attr|
      assert listing.respond_to?(attr), "listing should respond to #{attr}"
    end
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

  def test_rate_per_sqft_per_month
    listing = MLS::Listing.new(:rate => 10.5, :rate_units => '/sqft/mo', :size => 5)

    assert_equal 10.5,  listing.rate
    assert_equal 10.5,  listing.rate('/sqft/mo')
    assert_equal 126,   listing.rate('/sqft/yr')
    assert_equal 52.5,  listing.rate('/mo')
    assert_equal 630,   listing.rate('/yr')
    assert_equal 2100,   listing.rate('/desk/mo')
    assert_raises RuntimeError do
      listing.rate('/random')
    end
  end

  def test_rate_per_sqft_per_year
    listing = MLS::Listing.new(:rate => 126, :rate_units => '/sqft/yr', :size => 5)

    assert_equal 126,  listing.rate
    assert_equal 10.5,  listing.rate('/sqft/mo')
    assert_equal 126,   listing.rate('/sqft/yr')
    assert_equal 52.5,  listing.rate('/mo')
    assert_equal 630, listing.rate('/yr')
    assert_equal 2100,   listing.rate('/desk/mo')
    assert_raises RuntimeError do
      listing.rate('/random')
    end
  end

  def test_rate_per_month
    listing = MLS::Listing.new(:rate => 52.5, :rate_units => '/mo', :size => 5)

    assert_equal 52.5,  listing.rate
    assert_equal 10.5,  listing.rate('/sqft/mo')
    assert_equal 126,   listing.rate('/sqft/yr')
    assert_equal 52.5,  listing.rate('/mo')
    assert_equal 630, listing.rate('/yr')
    assert_equal 2100,   listing.rate('/desk/mo')
    assert_raises RuntimeError do
      listing.rate('/random')
    end
  end

  def test_rate_per_year
    listing = MLS::Listing.new(:rate => 630, :rate_units => '/yr', :size => 5)

    assert_equal 630,  listing.rate
    assert_equal 10.5,  listing.rate('/sqft/mo')
    assert_equal 126,   listing.rate('/sqft/yr')
    assert_equal 52.5,  listing.rate('/mo')
    assert_equal 630, listing.rate('/yr')
    assert_equal 2100,   listing.rate('/desk/mo')
    assert_raises RuntimeError do
      listing.rate('/random')
    end
  end

  def test_rate_per_desk_per_month
    listing = MLS::Listing.new(:rate => 2100, :rate_units => '/desk/mo', :size => 5)

    assert_equal 2100,  listing.rate
    assert_equal 10.5,  listing.rate('/sqft/mo')
    assert_equal 126,   listing.rate('/sqft/yr')
    assert_equal 2100,  listing.rate('/mo')
    assert_equal 25200, listing.rate('/yr')
    assert_equal 2100,   listing.rate('/desk/mo')
    assert_raises RuntimeError do
      listing.rate('/random')
    end
  end

  def test_rate_percision
    listing = MLS::Listing.new(:rate => 47, :rate_units => '/sqft/yr', :size => 5)

    assert_equal 3.92,  listing.rate('/sqft/mo')
    assert_equal 47,   listing.rate('/sqft/yr')
    assert_equal 19.58,  listing.rate('/mo')
    assert_equal 235, listing.rate('/yr')
    assert_equal 783.33,   listing.rate('/desk/mo')
  end

  def test_null_rate
    listing = MLS::Listing.new(:rate => nil, :rate_units => '/yr', :size => 5)

    assert_equal nil,  listing.rate
    assert_equal nil,  listing.rate('/sqft/mo')
    assert_equal nil,   listing.rate('/sqft/yr')
    assert_equal nil,  listing.rate('/mo')
    assert_equal nil, listing.rate('/yr')
    assert_equal nil,   listing.rate('/desk/mo')
    assert_equal nil, listing.rate('/random')
  end

end
