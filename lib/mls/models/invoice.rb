class Invoice < MLS::Model
  
  belongs_to :credit_card
  belongs_to :subscription
  
  def amount
    read_attribute(:amount) / 100.0 if read_attribute(:amount)
  end
  
  def status
    return "refunded" if refunded_at
    return "paid" if cleared_at
    return "pending"
  end
  
end
