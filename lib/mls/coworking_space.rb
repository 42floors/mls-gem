class CoworkingSpace < MLS::Model
  include MLS::Slugger

  belongs_to :unit

  has_one  :address
  has_one :property, through: :unit

  has_many :spaces
  has_many :addresses

end