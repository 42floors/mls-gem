class Membership < MLS::Model
  self.inheritance_column = nil
  
  has_many :accounts
  has_many :invoices
  has_many :coworking_spaces
  belongs_to :organization
  belongs_to :billing_contact, class_name: "Account"
  belongs_to :credit_card
  has_and_belongs_to_many :properties
  
  def cost_per_account
    read_attribute(:cost_per_account) / 100 if read_attribute(:cost_per_account)
  end
  
  def cost_per_property
    read_attribute(:cost_per_property) / 100 if read_attribute(:cost_per_property)
  end
  
  def cost_per_coworking_space
    read_attribute(:cost_per_coworking_space) / 100 if read_attribute(:cost_per_coworking_space)
  end
  
  def rate
    case type
    when "free"
      0
    when "elite_coworking"
      cost_per_coworking_space * coworking_space_ids.length
    when "elite"
      account_rate = cost_per_account * account_ids.length
      properties_rate = cost_per_property * ([property_ids.length, minimum_property_count].max - included_properties)
      properties_rate = 0 if properties_rate < 0
      account_rate + properties_rate
    else
      nil
    end
  end
  
end