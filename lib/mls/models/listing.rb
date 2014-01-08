class MLS::Listing < MLS::Resource

  WORKFLOW_STATES = %w(visible processing invisible expired)
  LEASE_STATES = %w(listed leased)
  TYPES = %w(lease sublease coworking_space)
  SPACE_TYPES = %w(unit floor building)
  LEASE_TERMS = ['Full Service', 'NNN', 'Modified Gross']
  RATE_UNITS = ['/sqft/yr', '/sqft/mo', '/mo', '/yr', '/desk/mo']
  USES = ["Office", "Creative", "Loft", "Medical Office", "Flex Space", "R&D", "Office Showroom", "Industrial", "Retail"]
  SOURCE_TYPES = %w(website flyer)
  CHANNELS = %w(excavator mls staircase broker_dashboard)

  attribute :id,                           Fixnum,   :serialize => :false
  attribute :address_id,                   Fixnum,   :serialize => :false
  attribute :slug,                         String,   :serialize => :false
  attribute :use,                          String,   :serialize => :if_present
  attribute :account_id,                   Fixnum
  attribute :private,                      Boolean,  :default => false, :serialize => false
  attribute :source,                       String
  attribute :source_url,                   String
  attribute :source_type,                  String, :serialize => :if_present
  attribute :channel,                      String, :serialize => :if_present
  attribute :photo_ids,                    Array,  :serialize => :if_present

  attribute :name,                         String
  attribute :type,                         String,   :default => 'lease'
  attribute :workflow_state,               String,   :default => 'visible'
  attribute :lease_state,                  String,   :default => 'listed'
  attribute :space_type,                   String,   :default => 'unit'
  attribute :unit,                         String
  attribute :floor,                        Fixnum
  attribute :description,                  String

  attribute :size,                   Fixnum
  attribute :maximum_contiguous_size,      Fixnum
  attribute :minimum_divisible_size,       Fixnum

  attribute :amenities,                    Hash
  attribute :lease_terms,                  String
  attribute :rate,                         Decimal
  attribute :rate_units,                   String,   :default => '/sqft/mo'
  attribute :low_rate,                     Decimal,  :serialize => :false
  attribute :high_rate,                    Decimal,  :serialize => :false
  attribute :sublease_expiration,          DateTime

  attribute :forecast_rate_per_year,             Decimal,  :serialize => :false
  attribute :forecast_rate_per_month,            Decimal,  :serialize => :false
  attribute :forecast_rate_per_sqft_per_month,   Decimal,  :serialize => :false
  attribute :forecast_rate_per_sqft_per_year,    Decimal,  :serialize => :false

  attribute :available_on,                 DateTime
  attribute :term,                         Fixnum
  attribute :term_units,            String,   :default => 'years'

  attribute :weekday_hours,                String
  attribute :saturday_hours,               String
  attribute :sunday_hours,                 String

  attribute :offices,                      Fixnum
  attribute :desks,                        Fixnum
  attribute :conference_rooms,             Fixnum
  attribute :bathrooms,                    Fixnum

  attribute :kitchen,                      Boolean
  attribute :showers,                      Boolean
  attribute :patio,                        Boolean
  attribute :reception_area,               Boolean
  attribute :ready_to_move_in,             Boolean
  attribute :furniture_available,          Boolean
  attribute :natural_light,                Boolean
  attribute :high_ceilings,                Boolean

  attribute :created_at,                   DateTime,  :serialize => :false
  attribute :updated_at,                   DateTime,  :serialize => :false
  attribute :touched_at,                   DateTime,  :serialize => :false
  attribute :leased_on,                    DateTime
  attribute :photography_requested_on,     DateTime,  :serialize => :false

  attribute :awesome_score,                Fixnum
  attribute :awesome_needs,                Array,  :serialize => :if_present
  attribute :awesome_label,                String

  attribute :flyer_id,                     Fixnum,    :serialize => :if_present
  attribute :floorplan_id,                 Fixnum,    :serialize => :if_present

  attribute :avatar_digest,                String,   :serialize => false

  # Counter Caches
  attribute :photos_count,                 Fixnum, :serialize => :false

  attr_accessor :property, :address, :agents, :account, :photos, :flyer, :floorplan, :videos, :similar_photos, :spaces, :primary_agent

  def avatar(size='150x100#', protocol='http')
    if avatar_digest
      "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
    else
      address.avatar(size, protocol)
    end
  end

  def processing?
    workflow_state == 'processing'
  end

  def leased?
    lease_state == 'leased'
  end

  def active?
    lease_state == 'listed' && workflow_state == 'visible'
  end

  def inactive?
    !self.active?
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

  def rate?
    !!@rate
  end
  
  # TODO: remove /desk/mo conversions
  def rate(units=nil)
    return nil if !@rate
    units ||= rate_units
    
    price = if rate_units == '/sqft/mo'
      if units == '/sqft/mo'
        @rate
      elsif units == '/sqft/yr'
        @rate * 12.0
      elsif units == '/mo'
        @rate * @size
      elsif units == '/yr'
        @rate * @size * 12.0
      elsif units == '/desk/mo'
        @rate * 200.0
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/sqft/yr'
      if units == '/sqft/mo'
        @rate / 12.0
      elsif units == '/sqft/yr'
        @rate
      elsif units == '/mo'
        (@rate * @size) / 12.0
      elsif units == '/yr'
        @rate * @size
      elsif units == '/desk/mo'
        (@rate / 12.0) * 200.0
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/mo'
      if units == '/sqft/mo'
        @rate / @size.to_f
      elsif units == '/sqft/yr'
        (@rate * 12) / @size.to_f
      elsif units == '/mo'
        @rate
      elsif units == '/yr'
        @rate * 12
      elsif units == '/desk/mo'
        (@rate / @size.to_f) * 200.0
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/yr'
      if units == '/sqft/mo'
        (@rate / 12.0) / @size.to_f
      elsif units == '/sqft/yr'
        @rate / @size.to_f
      elsif units == '/mo'
        @rate / 12.0
      elsif units == '/yr'
        @rate
      elsif units == '/desk/mo'
        ((@rate / 12.0) / @size.to_f) * 200.0
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/desk/mo'
      if units == '/sqft/mo'
        @rate / 200.0
      elsif units == '/sqft/yr'
        (@rate * 12) / 200.0
      elsif units == '/mo'
        @rate
      elsif units == '/yr'
        @rate * 12
      elsif units == '/desk/mo'
        @rate
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    end
    
    price.round(2)
  end
  
  # Creates a tour request for the listing.
  #
  # Paramaters::
  #
  # * +account+ - A +Hash+ of the user account. Valid keys are:
  #   * +:name+ - Name of the User requesting the tour (Required)
  #   * +:email+ - Email of the User requesting the tour (Required)
  #   * +:phone+ - Phone of the User requesting the tour
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
  #  listing.request_tour('name', 'email@address.com', info) # => #<MLS::Tour>
  #
  #  listing.request_tour('', 'emai', info) # => #<MLS::Tour> will have errors on account
  def request_tour(account, tour={})
    MLS::Tour.create(id, account, tour)
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
    hash[:spaces_attributes] = spaces.inject([]) { |acc, x| acc << x.to_hash; acc } if spaces
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

    def amenities
      @amenities ||= Yajl::Parser.new.parse(MLS.get('/listings/amenities').body).map(&:to_sym)
    end

  end

end


class MLS::Listing::Parser < MLS::Parser

  def photos=(photos)
    @object.photos = photos.map {|p| MLS::Photo::Parser.build(p)}
  end

  def similar_photos=(photos)
    @object.similar_photos = photos.map { |p| MLS::Photo::Parser.build(p) }
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

  def property=(property)
    @object.property = MLS::Property::Parser.build(property)
  end

  def agents=(agents)
    @object.agents = agents.map {|a| MLS::Account::Parser.build(a) }
  end
  
  def primary_agent=(agent)
    @object.primary_agent = MLS::Account::Parser.build(agent)
  end
end
