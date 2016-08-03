class EmailDigest < MLS::Model

  belongs_to :account
  accepts_nested_attributes_for :account
  
  def filter
    (read_attribute(:filter) || {}).with_indifferent_access
  end

end