class LeadProperty < MLS::Model
  
  belongs_to :lead
  belongs_to :property
  belongs_to :creator, class_name: "Account"
  
  has_many :lead_listings
  has_many :listings, through: :lead_listings

end