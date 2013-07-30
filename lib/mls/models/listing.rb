class MLS::Listing < MLS::Resource

  STATES = %w(processing listed leased expired)
  TYPES = %w(lease sublease coworking_space)
  SPACE_TYPES = %w(unit floor building)
  LEASE_TERMS = ['Full Service', 'NNN', 'Modified Gross']
  RATE_UNITS = ['/sqft/yr', '/sqft/mo', '/mo', '/yr', '/desk/mo']
  USES = ["Office", "Creative", "Loft", "Medical Office", "Flex Space", "R&D", "Office Showroom", "Industrial", "Retail"]
  SOURCE_TYPES = %w(website flyer)
  CHANNELS = %w(excavator mls staircase broker_dashboard)
  
  property :id,                           Fixnum,   :serialize => :false
  property :address_id,                   Fixnum,   :serialize => :false
  property :slug,                         String,   :serialize => :false
  property :use,                          String,   :serialize => :if_present
  property :account_id,                   Fixnum
  property :private,                      Boolean,  :default => false, :serialize => false
  property :source,                       String
  property :source_url,                   String
  property :source_type,                  String, :serialize => :if_present
  property :channel,                      String, :serialize => :if_present
  property :photo_ids,                    Array,  :serialize => :if_present
  
  property :name,                         String
  property :type,                         String,   :default => 'lease'
  property :state,                        String,   :default => 'listed'
  property :visible,                      Boolean, :default => true
  property :space_type,                   String,   :default => 'unit'
  property :unit,                         String
  property :floor,                        Fixnum
  property :description,                  String
  
  property :size,                   Fixnum
  property :maximum_contiguous_size,      Fixnum
  property :minimum_divisible_size,       Fixnum

  property :amenities,                    Hash
  property :lease_terms,                  String
  property :rate,                         Decimal
  property :rate_units,                   String,   :default => '/sqft/mo'
  property :low_rate,                     Decimal,  :serialize => :false
  property :high_rate,                    Decimal,  :serialize => :false
  property :rate_per_sqft_per_month,      Decimal,  :serialize => :false # need to make write methods for these that set rate to the according rate units. not accepted on api
  property :rate_per_sqft_per_year,       Decimal,  :serialize => :false
  property :rate_per_month,               Decimal,  :serialize => :false 
  property :rate_per_year,                Decimal,  :serialize => :false
  property :sublease_expiration,          DateTime
  
  property :forecast_rate_per_year,             Decimal,  :serialize => :false
  property :forecast_rate_per_month,            Decimal,  :serialize => :false
  property :forecast_rate_per_sqft_per_month,   Decimal,  :serialize => :false
  property :forecast_rate_per_sqft_per_year,    Decimal,  :serialize => :false

  property :available_on,                 DateTime
  property :maximum_term_length,          Fixnum
  property :minimum_term_length,          Fixnum

  property :offices,                      Fixnum
  property :conference_rooms,             Fixnum
  property :bathrooms,                    Fixnum
  
  property :kitchen,                      Boolean
  property :showers,                      Boolean
  property :patio,                        Boolean
  property :reception_area,               Boolean
  property :ready_to_move_in,             Boolean
  property :furniture_available,          Boolean
  property :natural_light,                Boolean
  property :high_ceilings,                Boolean
  
  property :created_at,                   DateTime,  :serialize => :false
  property :updated_at,                   DateTime,  :serialize => :false
  property :touched_at,                   DateTime,  :serialize => :false
  property :leased_on,                    DateTime
  property :photography_requested_on,     DateTime,  :serialize => :false

  property :awesome_score,                Fixnum
  property :awesome_needs,                Array,  :serialize => :if_present                
  property :awesome_label,                String

  property :flyer_id,                     Fixnum,    :serialize => :if_present
  property :floorplan_id,                 Fixnum,    :serialize => :if_present
  
  property :avatar_digest,                String,   :serialize => false
  
  # Counter Caches
  property :photos_count,                 Fixnum, :serialize => :false
  
  attr_accessor :address, :agents, :account, :photos, :flyer, :floorplan, :videos

  def avatar(size='150x100#', protocol='http')
    if avatar_digest
      "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
    else
      address.avatar(size, protocol)
    end
  end
  
  def lease?
    type == 'lease'
  end
  def sublease?
    type == 'sublease'
  end
  def coworking?
    type == 'coworking_space'
  end

  def leased?
    state == 'leased'
  end
  
  def space_name
    return name if !name.nil?
    
    case space_type
    when 'unit'
      if unit 
        "Unit #{unit}"
      elsif floor
        "#{floor.ordinalize} Floor"
      else
        "Unit Lease"
      end
    when 'building'
      "Entire Building"
    when 'floor'
      if floor
        "#{floor.ordinalize} Floor"
      elsif unit 
        "Unit #{unit}"
      else
        "Floor Lease"
      end
    end
  end

  
  
  # Creates a contact request for the listing.
  #
  # Paramaters::
  #
  # * +account+ - A +Hash+ of the user account. Valid keys are:
  #   * +:name+ - Name of the User requesting the contact (Required)
  #   * +:email+ - Email of the User requesting the contact (Required)
  #   * +:phone+ - Phone of the User requesting the contact
  # * +info+ - A optional +Hash+ of *company* info. Valid keys are:
  #   * +:message+ - Overrides the default message on the email sent to the broker
  #   * +:company+ - The name of the company that is interested in the space
  #   * +:population+ - The current number of employees at the company
  #   * +:growing+ - A boolean of weather or not the company is expecting to grow
  #
  # Examples:
  #
  #  #!ruby
  #  listing = MLS::Listing.find(@id)
  #  info => {:company => 'name', :population => 10, :funding => 'string', :move_id => '2012-09-12'}
  #  listing.request_contact('name', 'email@address.com', info) # => #<MLS::Contact>
  #  
  #  listing.request_contact('', 'emai', info) # => #<MLS::Contact> will have errors on account
  def request_contact(account, contact={})
    MLS::Contact.create(id, account, contact)
  end
  
  
  def create
    MLS.post('/listings', {:listing => to_hash}, 201, 400) do |response, code|
      raise MLS::Exception::UnexpectedResponse if ![201, 400].include?(code)
      MLS::Listing::Parser.update(self, response.body)
    end
  end

  def save
    return create unless id
    MLS.put("/listings/#{id}", {:listing => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLS::Listing::Parser.update(self, response.body)
        code == 200      
      else
        raise MLS::Exception::UnexpectedResponse, code
      end
    end
  end

  def to_hash
    hash = super
    hash[:address_attributes] = address.to_hash if address
    hash[:agents_attributes] = agents.inject([]) { |acc, x| acc << x.to_hash; acc } if agents
    hash[:photo_ids] = photos.map(&:id) if photos
    hash[:videos_attributes] = videos.map(&:to_hash) unless videos.blank?
    hash
  end
  
  def to_param
    "#{address.to_param}/#{id}"
  end

  def import #TODO test me
    result = :failure
    MLS.post('/import', {:listing => to_hash}, 400) do |response, code|
      case code
      when 200
        result = :duplicate
      when 201
        result = :created
      when 202
        result = :updated
      when 400
        result = :failure
      else
        raise MLS::Exception::UnexpectedResponse, code
      end
      MLS::Listing::Parser.update(self, response.body)
    end
    result
  end

  # TODO: Remove
  def all_photos
    warn "Listing#all_photos is deprecated"
    photos + address.photos
  end

  # TODO: Remove
  def all_videos
    warn "Listing#all_videos is deprecated"
    videos + address.videos
  end

  def similar 
    [] # Similar Listings not supported for now
  end

  class << self

    def find(id)
      response = MLS.get("/listings/#{id}")
      MLS::Listing::Parser.parse(response.body)
    end

    # currently supported options are filters, page, per_page, offset, order 
    def all(options={})
      response = MLS.get('/listings', options)
      MLS::Listing::Parser.parse_collection(response.body)
    end

    def import(attrs)
      model = self.new(attrs)
      {:status => model.import, :model => model}
    end

    def calculate(filters = {}, operation = nil, column = nil, group = nil)
      response = MLS.get("/listings/calculate", :filters => filters, :operation => operation, :column => column, :group => group)
      MLS::Parser.extract_attributes(response.body)[:listings]
    end

    def amenities
      @amenities ||= Yajl::Parser.new.parse(MLS.get('/listings/amenities').body).map(&:to_sym)
    end

  end

end


class MLS::Listing::Parser < MLS::Parser
  
  def photos=(photos)
    @object.photos = photos.map {|p| MLS::Photo::Parser.build(p)}
  end

  def videos=(videos)
    @object.videos = videos.map do |video|
      MLS::Video::Parser.build(video)
    end
  end

  def floorplan=(floorplan)
    @object.floorplan = MLS::Floorplan::Parser.build(floorplan)
  end

  def flyer=(flyer)
    @object.flyer = MLS::Flyer::Parser.build(flyer)
  end
   
  def address=(address)
    @object.address = MLS::Address::Parser.build(address)
  end
  
  def agents=(agents)
    @object.agents = agents.map {|a| MLS::Account::Parser.build(a) }
  end
  
end
