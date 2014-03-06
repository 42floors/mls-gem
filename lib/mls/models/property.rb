class MLSGem::Property < MLSGem::Resource

  attribute :id, Fixnum,   :serialize => :false
  attribute :name, String, :serialize => :false
  attribute :slug, String,   :serialize => :false
  
  attribute :latitude, Decimal
  attribute :longitude, Decimal
  
  attribute :description, String
  attribute :neighborhood, String
  attribute :constructed, Fixnum
  attribute :size, Fixnum
  attribute :floors, Fixnum
  attribute :leed_certification, String
  attribute :style, String
  attribute :height, Decimal
  attribute :lot_size, Decimal

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
      "#{protocol}://#{MLSGem.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
    else
      params[:size] = params[:size].match(/\d+x\d+/)[0]
      "#{protocol}://maps.googleapis.com/maps/api/streetview?" + params.map{|k,v| k.to_s + '=' + URI.escape(v.to_s) }.join('&')
    end
  end

  def save
    MLSGem.put("/properties/#{id}", {:address => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLSGem::Property::Parser.update(self, response.body)
        code == 200      
      else
        raise MLSGem::Exception::UnexpectedResponse, code
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
      response = MLSGem.get("/properties/#{id}")
      MLSGem::Property::Parser.parse(response.body)
    end

    # currently supported options are :include, :where, :limit, :offset
    def all(options={})
      response = MLSGem.get('/properties', options)
      MLSGem::Property::Parser.parse_collection(response.body)
    end

    def amenities
      @amenities ||= Yajl::Parser.new(:symbolize_keys => true).parse(MLSGem.get('/properties/amenities').body)
    end

  end
  
end


class MLSGem::Property::Parser < MLSGem::Parser

  def listings=(listings)
    @object.listings = listings.map { |data|
      listing = MLSGem::Listing::Parser.build(data)
      listing.address = @object
      listing
    }
  end

  def photos=(photos)
    @object.photos = photos.map {|p| MLSGem::Photo::Parser.build(p)}
  end

  def videos=(videos)
    @object.videos = videos.map do |video|
      MLSGem::Video::Parser.build(video)
    end
  end

  def addresses=(addresses)
    @object.addresses = addresses.map {|a| MLSGem::Property::Parser.build(addresses)}
  end
end
