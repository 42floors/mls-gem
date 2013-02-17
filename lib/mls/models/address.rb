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
  property :min_rate_per_sqft_per_year, Decimal, :serialize => :if_present
  property :max_rate_per_sqft_per_year, Decimal, :serialize => :if_present
  property :max_size, Fixnum, :serialize => :if_present
  property :min_size, Fixnum, :serialize => :if_present
  property :comments, String
  property :year_built, Fixnum
  property :total_size, Fixnum
  property :floors, Fixnum

  property :lobby_attendant, Boolean
  property :gym, Boolean

  property :common_bike_storage, Boolean
  property :common_kitchen, Boolean
  property :common_showers, Boolean
  property :onsite_parking, Boolean
  property :bikes_allowed, Boolean
  property :dog_friendly, Boolean
  property :common_bathrooms, Boolean
  property :onsite_security_guard, Boolean

  property :leed_certification, String
  
  # Counter caches
  property :listings_count, Fixnum, :serialize => :false
  property :leased_listings_count, Fixnum, :serialize => :false
  property :hidden_listings_count, Fixnum, :serialize => :false
  property :import_listings_count, Fixnum, :serialize => :false
  property :active_listings_count, Fixnum, :serialize => :false

  property :avatar_digest, String,   :serialize => false

  attr_accessor :listings, :listing_types, :photos, :videos

  # should include an optional use address or no_image image
  def avatar(size='100x200#', protocol='http')
    params = {
      :size => size,
      :format => 'png',
      :sensor => false,
      :location => [formatted_address],
      :fov => 120
    }

    if avatar_digest
      "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
    else
      params[:size] = params[:size].match(/\d+x\d+/)[0]
      "#{protocol}://maps.googleapis.com/maps/api/streetview?" + params.map{|k,v| k.to_s + '=' + URI.escape(v.to_s) }.join('&')
    end
  end

  def save
    MLS.put("/addresses/#{id}", {:address => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLS::Address::Parser.update(self, response.body)
        code == 200      
      else
        raise MLS::Exception::UnexpectedResponse, code
      end
    end
  end

  def to_hash
    hash = super
    hash[:photo_ids] = photos.map(&:id) if photos
    hash[:videos_attributes] = videos.map(&:to_hash) unless videos.blank?
    hash
  end

  def to_param
    [state, city, "#{street_number} #{street}"].map(&:parameterize).join('/')
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

  def amenities
    MLS.address_amenities
  end

  def find_listings(space_available, floor, unit)
    response = MLS.get("/addresses/#{id}/find_listings", 
      :floor => floor, :unit => unit, :space_available => space_available)
    MLS::Listing::Parser.parse_collection(response.body)
  end

  class << self
    
    def query(q)
      response = MLS.get('/addresses/query', :query => q)
      MLS::Address::Parser.parse_collection(response.body)
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

  def listing_types=(listing_types)
    @object.listing_types = listing_types
  end

  def photos=(photos)
    @object.photos = photos.map {|p| MLS::Photo::Parser.build(p)}
  end

  def videos=(videos)
    @object.videos = videos.map do |video|
      MLS::Video::Parser.build(video)
    end
  end
end
