class Subscription < MLS::Model

  belongs_to :account
  
  def filter
    (read_attribute(:filter) || {}).with_indifferent_access
  end

end