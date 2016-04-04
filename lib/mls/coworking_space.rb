class CoworkingSpace < MLS::Model
  include MLS::Slugger
  include MLS::Avatar
  
  belongs_to  :organization
  belongs_to  :property
  has_many    :image_orderings, as: :subject
  has_many    :photos, through: :image_orderings, source: :image
  has_many    :spaces
  has_many    :addresses, :through => :property
  
  accepts_nested_attributes_for :spaces
  
  def name
    output = organization.name
    output += " - " + read_attribute(:name) if read_attribute(:name)
    output
  end

end
