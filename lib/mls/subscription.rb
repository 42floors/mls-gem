class Subscription < MLS::Model
  self.inheritance_column = nil

  belongs_to :membership
  belongs_to :subject, polymorphic: true
  belongs_to :credit_card

  def name
    case self.type
    when "unlimited"
      "Unlimited Premium Listings"
    when "premium"
      "Premium Listings"
    when "elite"
      "Elite Account"
    when "coworking"
      "Coworking Space"
    end
  end
    
  def cost
    read_attribute(:cost) / 100.0 if read_attribute(:cost)
  end
  
  def update_listing_status
    req = Net::HTTP::Post.new("/subscriptions/#{self.id}/update_listing_status")
    Subscription.connection.instance_variable_get(:@connection).send_request(req)
  end
end