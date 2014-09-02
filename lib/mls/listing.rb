class Listing < MLS::Model
  
  include MLS::Slugger

  WORKFLOW_STATES = %w(visible processing invisible expired)
  LEASE_STATES = %w(listed leased)
  TYPES = %w(lease sublease coworking_space)
  SPACE_TYPES = %w(unit floor building)
  LEASE_TERMS = ['Full Service', 'NNN', 'Modified Gross']
  RATE_UNITS = ['/sqft/yr', '/sqft/mo', '/mo', '/yr', '/desk/mo']
  USES = ["Office", "Creative", "Loft", "Medical Office", "Flex Space", "R&D", "Office Showroom", "Industrial", "Retail"]
  SOURCE_TYPES = %w(website flyer)
  CHANNELS = %w(excavator mls staircase broker_dashboard)

  belongs_to :avatar, :class_name => 'Photo'
  belongs_to :floorplan
  belongs_to :flyer
  belongs_to :property
  
  has_many :photos, -> { order('photos.order ASC') }, :as => :subject, :inverse_of => :subject
  has_many :agents, :class_name => 'Account'
  
  # has_one :address
  # has_one :contact
  #
  # has_many :addresses
  
  # has_many :comments
  # has_many :regions
  # has_many :agents

  # has_many :favoritizations, :foreign_key => :favorite_id
  # has_many :accounts, :through => :favoritizations
  # has_many :inquiries, :as => :subject, :inverse_of => :subject
  # has_many :agencies, -> { order('"order"') }, :dependent => :destroy, :inverse_of => :subject, :as => :subject
  # has_many :agents, -> { order('agencies.order') }, :through => :agencies, :inverse_of => :listings, :source => :agent
  # has_many :email_proxies, :as => :subject, :inverse_of => :subject
  # has_many :lead_listings, :dependent => :delete_all
  #
  # has_and_belongs_to_many :uses, :inverse_of => :listings

  def contact
    agents.first
  end
  alias_method :default_contact, :contact
  
  def rate(units=nil)
    return nil if !read_attribute(:rate)
    units ||= rate_units

    price = if rate_units == '/sqft/mo'
      if units == '/sqft/mo'
        read_attribute(:rate)
      elsif units == '/sqft/yr'
        read_attribute(:rate) * 12.0
      elsif units == '/mo'
        read_attribute(:rate) * size
      elsif units == '/yr'
        read_attribute(:rate) * size * 12.0
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/sqft/yr'
      if units == '/sqft/mo'
        read_attribute(:rate) / 12.0
      elsif units == '/sqft/yr'
        read_attribute(:rate)
      elsif units == '/mo'
        (read_attribute(:rate) * size) / 12.0
      elsif units == '/yr'
        read_attribute(:rate) * size
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/mo'
      if units == '/sqft/mo'
        read_attribute(:rate) / size.to_f
      elsif units == '/sqft/yr'
        (read_attribute(:rate) * 12) / size.to_f
      elsif units == '/mo'
        read_attribute(:rate)
      elsif units == '/yr'
        read_attribute(:rate) * 12
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    elsif rate_units == '/yr'
      if units == '/sqft/mo'
        (read_attribute(:rate) / 12.0) / size.to_f
      elsif units == '/sqft/yr'
        read_attribute(:rate) / size.to_f
      elsif units == '/mo'
        read_attribute(:rate) / 12.0
      elsif units == '/yr'
        read_attribute(:rate)
      else
        raise "Invalid rate conversion (#{rate_units} => #{units})"
      end

    end

    price.round(2)
  end
  
  def name
    return read_attribute(:name) if read_attribute(:name)

    case space_type
    when 'unit'
      if unit
        "Unit #{unit}"
      elsif floor
        "#{floor.ordinalize} Floor Unit"
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

end