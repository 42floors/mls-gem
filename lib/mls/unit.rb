class Unit < MLS::Model
  self.inheritance_column = nil

  include MLS::Slugger
  include MLS::Avatar
  
  TYPES = %w(unit floor building)
  AMENITIES = %W(kitchen showers outdoor_space reception turnkey build_to_suit
    furniture natural_light high_ceilings plug_and_play additional_storage
    storefront offices conference_rooms bathrooms)

  belongs_to :property
  belongs_to :floorplan, :class_name => 'Document'


  has_many :listings
  has_many :references, as: :subject
  has_many :image_orderings, as: :subject
  has_many :photos, through: :image_orderings, source: :image
  # has_many :photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_and_belongs_to_many :uses
  
  accepts_nested_attributes_for :uses

  def tags
    read_attribute(:tags) || []
  end

  def name
    name = ""
    case self.type
    when 'unit'
      name += "Unit"
      name += " #{self.number}" if self.number
      name += " (Floor #{self.floor})" if self.floor
    when 'floor'
      name += "Floor"
      name += " #{self.floor}" if self.floor
      name += " (Unit #{self.number})" if self.number
    when 'building'
      "Entire Building"
    end
    name
  end

end
