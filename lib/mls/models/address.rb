class MLS::Address < MLS::Resource

  property :id, Fixnum,   :serialize => :if_present
  property :name, String, :serialize => :false
  property :slug, String,   :serialize => :if_present
  
  property :latitude, Decimal
  property :longitude, Decimal
  
  property :formatted_address, String
  property :street_number, String
  property :street, String
  property :neighborhood, String
  property :city, String
  property :county, String
  property :state, String
  property :country, String
  property :postal_code, String
  property :min_rate_per_year, Decimal, :serialize => :if_present
  property :max_rate_per_year, Decimal, :serialize => :if_present
  property :max_size, Fixnum, :serialize => :if_present
  property :min_size, Fixnum, :serialize => :if_present
  property :comments, String
  property :year_built, Fixnum
  property :total_size, Fixnum
  property :floors, Fixnum
  property :internet_speed, Decimal
  property :parking_garage, Boolean
  property :lobby_attendant, Boolean
  property :gym, Boolean
  property :leed_certification, String

  

  attr_accessor :listings, :listing_kinds, :photos

  class << self
    
    def query(q)
      response = MLS.get('/addresses/query', :query => q)
      MLS::Address::Parser.parse_collection(response.body)
    end

    # Bounds is passed as 'n,e,s,w' or [n, e, s, w]
    def box_cluster(bounds, zoom, filters={})
      response = MLS.get('/addresses/box_cluster', :bounds => bounds, :zoom => zoom, :filters => filters)
    end

    def find(id)
      response = MLS.get("/addresses/#{id}")
      MLS::Address::Parser.parse(response.body)
    end
    
    def all(filters = {})
      response = MLS.get('/addresses', :filter => filters)
      MLS::Address::Parser.parse_collection(response.body)
    end
    
  end
  
end


class MLS::Address::Parser < MLS::Parser

  def listings=(listings)
    @object.listings = listings.map {|d| MLS::Listing::Parser.build(d)}
  end

  def listing_kinds=(listing_kinds)
    @object.listing_kinds = listing_kinds
  end

  def photos=(photos)
    @object.photos = photos.map {|d| MLS::Photo.new({:digest => d})}
  end
end
