class Lead < MLS::Model

  belongs_to  :account
  belongs_to  :agent, class_name: "Account"

  has_many    :lead_properties
  has_many    :lead_listings
  
end