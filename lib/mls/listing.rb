class Listing < MLS::Model
  self.inheritance_column = nil

  include MLS::Slugger
  include MLS::Avatar

  UNIT_TYPES = %w(unit floor building)
  FLOORS = ["Basement", "Mezzanine", "Penthouse", "Concourse", "Lower Level"] + (1..150).to_a
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
  AMENITIES = %W(kitchen showers outdoor_space reception turnkey build_to_suit
                    furniture natural_light high_ceilings plug_and_play additional_storage
                    storefront offices conference_rooms bathrooms)

  belongs_to :flyer, :class_name => 'Document'
  belongs_to :floorplan, :class_name => 'Document'
  belongs_to :property

  has_many :ownerships, as: :asset
  has_many :accounts, through: :ownerships, source: :account, inverse_of: :listings
  has_many :image_orderings, as: :subject
  has_many :photos, through: :image_orderings, source: :image
  
  has_and_belongs_to_many :uses
  
  has_one  :address
  has_many :addresses
  has_many :references, as: :subject

  accepts_nested_attributes_for :uses, :ownerships, :image_orderings
  
  def is_elite?
    ((property.elite_account_ids || []) & accounts.map(&:id)).length > 0
  end
  
  def premium_property?
    Subscription.filter(started_at: true, ends_at: false, type: "premium", subject_type: "Property", subject_id: self.property_id).count > 0
  end

  def contacts
    if ownerships.loaded?
      @contacts ||= ownerships.select{|o| o.receives_inquiries }.map(&:account)
    else
      @contacts ||= ownerships.eager_load(:account).filter(:receives_inquiries => true).map(&:account)
    end
  end

  def lead_contacts
    if ownerships.loaded?
      @lead_contacts ||= ownerships.select{|o| o.lead}.map(&:account)
    else
      @lead_contacts ||= ownerships.eager_load(:account).filter(:lead => true).map(&:account)
    end
  end

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
  
  def regions
    Region.where(:id => self.region_ids)
  end
  
  def longitude
    location.x
  end

  def latitude
    location.y
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
    return "New Listing" if !self.id
    name = ""
    if self.unit_type == "building"
      name += "Entire Building"
    else
      name = "Unit #{self.unit}" if self.unit.present?
      name += " (" if self.unit.present? && self.floor.present?
      name += "Floor #{self.floor}" if self.floor.present?
      name += ")" if self.unit.present? && self.floor.present?
    end
    name = "Space" if name.blank?
    name
  end
end
