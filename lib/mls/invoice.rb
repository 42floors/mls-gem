class Invoice < MLS::Model
  
  belongs_to :credit_card
  belongs_to :membership
  
end
