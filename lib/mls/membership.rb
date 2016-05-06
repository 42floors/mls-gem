class Membership < MLS::Model
  
  belongs_to :account
  
  def cost
    read_attribute(:cost) / 100 if read_attribute(:cost)
  end
  
  def cost_per_property
    read_attribute(:cost_per_property) / 100 if read_attribute(:cost_per_property)
  end
  
end