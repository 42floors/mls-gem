class Subscription < MLS::Model

  belongs_to :membership
  belongs_to :subject, polymorphic: true
  belongs_to :credit_card

    
  def cost
    read_attribute(:cost) / 100 if read_attribute(:cost)
  end
end