class CoworkingSpace < MLS::Model
  include MLS::Slugger
  include MLS::Avatar
  
  belongs_to  :organization
  belongs_to  :property
  has_many    :image_orderings, as: :subject, dependent: :destroy
  has_many    :photos, through: :image_orderings, source: :image
  has_many    :spaces
  has_many    :addresses, :through => :property
  
  def name
    output = organization.name
    output += " - " + read_attribute(:name) if read_attribute(:name)
    output
  end

end