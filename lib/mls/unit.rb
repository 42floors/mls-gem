class Unit < MLS::Model
  include MLS::Slugger
  include MLS::Avatar

  belongs_to :property
  belongs_to :floorplan

  has_many :listings
  has_many :photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_and_belongs_to_many :uses

  def tags
    read_attribute(:tags) || []
  end
  
  def name
    return read_attribute(:name) if read_attribute(:name)
    name = ""
    case self.type
    when 'unit'
      name += "Unit"
      name += " #{self.number}" if self.number
      name += " (Floor #{self.number})" if self.number
    when 'floor'
      name += "Floor #{self.number}" if self.floor
      name += " (Unit #{self.number})" if self.number
    when 'building'
      "Entire Building"
    end
  end

end
