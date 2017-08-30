class EmailDigest < MLS::Model

  belongs_to :account
  accepts_nested_attributes_for :account
  
  def filter
    JSON.parse (read_attribute(:filter) || {}).to_json, object_class: OpenStruct
  end

end