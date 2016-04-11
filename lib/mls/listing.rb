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

  belongs_to :flyer, :class_name => 'Document'
  belongs_to :unit
  belongs_to :property

  has_many :photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_many :ownerships, as: :asset
  has_many :agents, through: :ownerships, source: :account, inverse_of: :listings

  has_one  :address
  has_many :addresses

  accepts_nested_attributes_for :unit, :ownerships

  filter_on :organization_id, -> (v) {
    where(organization_id: v)
  }

  def contacts
    @contacts ||= ownerships.filter(:receives_inquiries => true).map(&:account)
  end

  def lead_contact
    @lead_contact ||= ownerships.filter(:lead => true).first.try(:account)
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
    unit.name
  end
end
