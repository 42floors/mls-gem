class Membership < MLS::Model
  self.inheritance_column = nil
  
  has_many :accounts
  has_many :invoices
  has_many :subscriptions
  belongs_to :organization
  belongs_to :billing_contact, class_name: "Account"
  belongs_to :credit_card
  
  accepts_nested_attributes_for :subscriptions
  
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
    subscriptions.sum(&:cost)
  end
  
end