class Lead < MLS::Model

  belongs_to  :account
  belongs_to  :agent, class_name: "Account"

  has_many    :recommendations
  # Removing lead_listings after recommendations release
  has_many    :lead_listings

end
