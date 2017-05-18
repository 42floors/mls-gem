class Subscription < MLS::Model
  self.inheritance_column = nil
  
  has_many :accounts
  has_many :invoices
  has_many :services
  belongs_to :organization
  belongs_to :billing_contact, class_name: "Account"
  belongs_to :credit_card
  
  has_and_belongs_to_many     :invoice_recipients, class_name: 'EmailAddress'
  
  accepts_nested_attributes_for :services
  
  def cost
    servicete(:cost) / 100.0 if read_attribute(:cost)
  end

end