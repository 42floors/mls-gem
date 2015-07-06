class CoworkingSpace < MLS::Model
  include MLS::Slugger
  include MLS::Avatar
  
  belongs_to  :organization
  belongs_to  :property
  has_many    :image_orderings, as: :subject, dependent: :destroy
  has_many    :spaces
  has_many    :addresses, :through => :property

end