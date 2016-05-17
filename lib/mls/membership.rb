class Membership < MLS::Model
  
  has_many :accounts
  belongs_to :billing_contact, class_name: "Account"
  has_and_belongs_to_many :properties
  
  def cost_per_account
    read_attribute(:cost_per_account) / 100 if read_attribute(:cost_per_account)
  end
  
  def cost_per_property
    read_attribute(:cost_per_property) / 100 if read_attribute(:cost_per_property)
  end
  
  def rate
    account_rate = cost_per_account * account_ids.length
    account_rate = cost_per_account if account_rate <= 0
    properties_rate = cost_per_property * (property_ids.length - included_properties)
    properties_rate = 0 if properties_rate < 0
    account_rate + properties_rate
  end
  
end