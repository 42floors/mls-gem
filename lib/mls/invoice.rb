class Invoice < MLS::Model
  
  belongs_to :credit_card
  belongs_to :membership
  
  def amount
    read_attribute(:amount) / 100.0 if read_attribute(:amount)
  end
  
end
