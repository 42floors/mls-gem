class Subscription < MLS::Model
  self.inheritance_column = nil

  belongs_to :membership
  belongs_to :subject, polymorphic: true
  belongs_to :credit_card

  def type
    case self.subject_type
    when "Property"
      "Premium Property"
    when "Account"
      "Elite Membership"
    when "CoworkingSpace"
      "Coworking Space"
    end
  end
    
  def cost
    read_attribute(:cost) / 100.0 if read_attribute(:cost)
  end
end