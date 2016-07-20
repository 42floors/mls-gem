class CoworkingSpace < MLS::Model
  include MLS::Slugger
  include MLS::Avatar
  
  belongs_to  :organization
  belongs_to  :property
  belongs_to  :membership
  has_many    :image_orderings, as: :subject
  has_many    :photos, through: :image_orderings, source: :image
  has_many    :spaces
  has_many    :addresses, :through => :property
  
  has_many    :ownerships, as: :asset
  has_many    :accounts, through: :ownerships
  
  accepts_nested_attributes_for :spaces, :ownerships, :accounts
  
  def display_name
    output = organization.name
    output += " - " + read_attribute(:name) if read_attribute(:name)
    output
  end
  
  def longitude
    location.x
  end

  def latitude
    location.y
  end

end
