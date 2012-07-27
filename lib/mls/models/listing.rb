class MLS::Listing < MLS::Resource
  
  KINDS = %w(lease sublease coworking)
  SPACE_TYPES = %w(unit floor building)
  LEASE_TYPES = ['Full Service', 'NNN', 'Gross', 'Industrial Gross', 'Modified Gross', 'Triple Net', 'Modified Net']
  RATE_UNITS = ['ft^2/year', 'ft^2/month', 'desk/month']
  USES = ["Office", "Creative", "Loft", "Medical Office", "Flex Space", "R&D", "Office Showroom", "Industrial", "Retail"]
  
  property :id,                           Fixnum
  property :address_id,                   Fixnum
  property :use_id,                       Fixnum
  property :use,                          String
  property :account_id,                   Fixnum
  property :hidden,                       Boolean, :default => false
    
  property :name,                         String
  property :kind,                         String, :default => 'lease'
  property :space_type,                   String, :default => 'unit'
  property :unit,                         String
  property :floor,                        Fixnum
  property :comments,                     String
    
  property :total_size,                   Fixnum
  property :maximum_contiguous_size,      Fixnum
  property :minimum_divisable_size,       Fixnum

  property :lease_type,                   String
  property :rate,                         Decimal
  property :rate_units,                   String, :default => 'ft^2/month'
  property :rate_per_month,               Decimal
  property :rate_per_year,                Decimal
  property :tenant_improvements,          String
  property :nnn_expenses,                 Decimal
  property :sublease_expiration,          DateTime

  property :available_on,                 DateTime
  property :maximum_term_length,          Fixnum
  property :minimum_term_length,          Fixnum

  property :offices,                      Fixnum
  property :conference_rooms,             Fixnum
  property :bathrooms,                    Fixnum
  property :desks,                        Fixnum
  
  property :kitchen,                      Boolean, :default => false
  property :showers,                      Boolean, :default => false
  property :bike_rack,                    Boolean, :default => false
  property :bikes_allowed,                Boolean, :default => false
  property :server_room,                  Boolean, :default => false
  property :reception_area,               Boolean, :default => false
  property :turnkey,                      Boolean, :default => false
  property :patio,                        Boolean, :default => false
  property :copy_room,                    Boolean, :default => false
  property :dog_friendly,                 Boolean, :default => false
  property :cabling,                      Boolean, :default => false
  property :ready_to_move_in,             Boolean, :default => false
  property :recent_space_improvements,    Boolean, :default => false
  property :printers,                     Boolean, :default => false
  property :furniture_available,          Boolean, :default => false
  
  property :created_at,                   DateTime
  property :updated_at,                   DateTime
  
  
  attr_accessor :address, :agents, :photos

  def sublease?
    kind == 'sublease'
  end

  def create
    MLS.post('/listings', to_hash) do |code, response|
      case code
      when 201
        MLS::Account::Parser.update(self, response.body)
        true
      when 400
        MLS::Account::Parser.update(self, response.body)
        false
      else
        MLS.handle_response(response)
        raise "shouldn't get here...."
      end
    end
  end

  def to_hash
    hash = super
    hash[:address_attributes] = address.to_hash if address
    hash
  end

  class << self
    
    def find(id)
      response = MLS.get("/listings/#{id}")
      MLS::Listing::Parser.parse(response.body)
    end

  end
  
end


class MLS::Listing::Parser < MLS::Parser
  
  def photos=(photos)
    @object.photos = photos.map {|d| MLS::Photo.new(d) }
  end
   
  def address=(address)
    @object.address = MLS::Address::Parser.build(address)
  end
  
  def agents=(agents)
    @object.agents = agents.map {|a| MLS::Account::Parser.build(a) }
  end
  
end
