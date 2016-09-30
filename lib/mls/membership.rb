class Membership < MLS::Model
  self.inheritance_column = nil
  
  has_many :accounts
  has_many :invoices
  has_many :subscriptions
  belongs_to :organization
  belongs_to :billing_contact, class_name: "Account"
  belongs_to :credit_card
  
  accepts_nested_attributes_for :subscriptions
  
  def rate
    subscriptions.select{|x| !x.ends_at}.map(&:cost).compact.sum
  end
  
  def costs
    (read_attribute(:costs) || {}).with_indifferent_access
  end
  
  def value
    read_attribute(:value) / 100.0 if read_attribute(:value)
  end

end