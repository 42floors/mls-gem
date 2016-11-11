class Subscription < MLS::Model
  self.inheritance_column = nil

  belongs_to :membership
  belongs_to :subject, polymorphic: true
  belongs_to :credit_card

  def type
    case self.type
    when "unlimited"
      "Unlimited"
    when "premium"
      "Premium Property"
    when "elite"
      "Elite Membership"
    when "coworking"
      "Coworking Space"
    end
  end
    
  def cost
    read_attribute(:cost) / 100.0 if read_attribute(:cost)
  end
end