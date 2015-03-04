class Listing < MLS::Model
  self.inheritance_column = nil

  include MLS::Slugger

  SPACE_TYPES = %w(unit floor building)
  TYPES = %w(Sale Lease Sublease)
  TERMS = ['Full Service', 'Net Lease', 'NN', 'NNN', 'Absolute NNN', 'Gross Lease', 'Modified Gross', 'Industrial Gross', 'Absolute Gross', 'Ground Lease', 'Other']
  SALE_TERMS = ['Cash to Seller', 'Purchase Money Mtg.', 'Owner Financing', 'Build-to-Suit', 'Sale/Leaseback', 'Other']
  RATE_UNITS = {
    '/sqft/yr' => 'rate_per_sqft_per_year',
    '/sqft/mo' => 'rate_per_sqft_per_month',
    '/mo' => 'rate_per_month',
    '/yr' => 'rate_per_year',
  }
  TERM_UNITS = ['years', 'months']
  AMENITIES = %W(kitchen showers outdoor_space reception turnkey build_to_suit furniture
                  natural_light high_ceilings plug_and_play additional_storage storefront)

  belongs_to :floorplan
  belongs_to :flyer
  belongs_to :unit

  has_one  :property,  :through => :unit

  has_many :photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_many :agencies, -> { order(:order) }, :as => :subject
  has_many :agents, -> { order('agencies.order') }, :through => :agencies, :source => :agent

  has_one  :address
  has_many :addresses

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

  def contact
    @contact ||= agents.first
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
    else
      read_attribute(:rate)

    end

    price.round(2)
  end

  def lease? # TODO: test me
    type == 'Lease'
  end

  def sublease? # TODO: test me
    type == 'Sublease'
  end

  def sale?
    type == 'Sale'
  end

  def name
    return read_attribute(:name) if read_attribute(:name)
    case space_type
    when 'unit'
      if unit.try(:number)
        "Unit #{unit.number}"
      elsif unit.try(:floor)
        "#{unit.floor.to_i.ordinalize} Floor Unit"
      else
        "Unit Lease"
      end
    when 'building'
      "Entire Building"
    when 'floor'
      if unit.try(:floor) && unit.floor == unit.floor.to_i.to_s
        "#{unit.floor.to_i.ordinalize} Floor"
      elsif unit.try(:floor)
        unit.floor
      elsif unit.try(:number)
        "Unit #{unit.number}"
      else
        "Floor Lease"
      end
    end
  end
end
