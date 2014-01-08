class MLS::Property < MLS::Resource

  attribute :id, Fixnum,   :serialize => :false
  attribute :name, String, :serialize => :false
  attribute :slug, String,   :serialize => :false
  
  attribute :latitude, Decimal
  attribute :longitude, Decimal
  
  attribute :description, String
  attribute :contructed, Fixnum
  attribute :size, Fixnum
  attribute :floors, Fixnum
  attribute :leed_certification, String
  attribute :style, String
  attribute :height, Float
  attribute :lot_size, Float

  attribute :amenities, Hash
  
  # Counter caches
  attribute :listings_count, Fixnum, :serialize => :false

  attribute :avatar_digest, String,   :serialize => false

  attr_accessor :listings, :addresses, :photos, :videos

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
    MLS.put("/properties/#{id}", {:address => to_hash}, 400) do |response, code|
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
    slug
  end

  class << self

    def find(id)
      response = MLS.get("/properties/#{id}")
      MLS::Address::Parser.parse(response.body)
    end

    # currently supported options are :include, :where, :limit, :offset
    def all(options={})
      response = MLS.get('/properties', options)
      MLS::Address::Parser.parse_collection(response.body)
    end

    def amenities
      @amenities ||= Yajl::Parser.new(:symbolize_keys => true).parse(MLS.get('/properties/amenities').body)
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

  def photos=(photos)
    @object.photos = photos.map {|p| MLS::Photo::Parser.build(p)}
  end

  def videos=(videos)
    @object.videos = videos.map do |video|
      MLS::Video::Parser.build(video)
    end
  end

  def addresses=(addresses)
    @object.addresses = addresses.map {|a| MLS::Address::Parser.build(addresses)}
  end
end
