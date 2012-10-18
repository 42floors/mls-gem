class MLS::Address < MLS::Resource

  property :id, Fixnum,   :serialize => :false
  property :name, String, :serialize => :false
  property :slug, String,   :serialize => :false
  
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
  
  # Counter caches
  property :listings_count, Fixnum, :serialize => :false
  property :leased_listings_count, Fixnum, :serialize => :false
  property :hidden_listings_count, Fixnum, :serialize => :false
  property :import_listings_count, Fixnum, :serialize => :false
  property :active_listings_count, Fixnum, :serialize => :false

  attr_accessor :listings, :listing_kinds, :photos

  # should include an optional use address or no_image image
  def avatar(size='100x200', protocol='http')
    params = {
      :size => size,
      :format => 'png',
      :sensor => false,
      :location => [formatted_address],
      :fov => 120
    }

    "#{protocol}://maps.googleapis.com/maps/api/streetview?" + params.map{|k,v| k.to_s + '=' + URI.escape(v.to_s) }.join('&')
  end

  def to_hash
    hash = super
    hash[:photo_ids] = photos.map(&:id) if photos
    hash
  end

  def to_param
    [state, city, name].map(&:parameterize).join('/')
  end

  def url
    if defined? Rails
      case Rails.env
      when "production"
        host = "42floors.com"
      when "staging"
        host = "staging.42floors.com"
      when "development","test"
        host = "spire.dev"
      end
    else
      host = "42floors.com"
    end
    "http://#{host}/#{slug}"
  end

  class << self
    
    def query(q)
      response = MLS.get('/addresses/query', :query => q)
      MLS::Address::Parser.parse_collection(response.body)
    end

    # Bounds is passed as 'n,e,s,w' or [n, e, s, w]
    def box_cluster(bounds, zoom, where={})
      MLS.get('/addresses/box_cluster', :bounds => bounds, :zoom => zoom, :where => where)
    end

    def find(id)
      response = MLS.get("/addresses/#{id}")
      MLS::Address::Parser.parse(response.body)
    end

    # currently supported options are :include, :where, :limit, :offset
    def all(options={})
      response = MLS.get('/addresses', options)
      MLS::Address::Parser.parse_collection(response.body)
    end
    
  end
  
end


class MLS::Address::Parser < MLS::Parser

  def listings=(listings)
    @object.listings = listings.map { |data|
      listing = MLS::Listing::Parser.build(data)
      listing.address = @object
      listing
    }
  end

  def listing_kinds=(listing_kinds)
    @object.listing_kinds = listing_kinds
  end

  def photos=(photos)
    @object.photos = photos.map do |p|
      MLS::Photo.new(:digest => p[:digest], :id => p[:id].to_i)
    end
  end
end
