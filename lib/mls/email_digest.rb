class EmailDigest < MLS::Model

  belongs_to :search
  belongs_to :account
  accepts_nested_attributes_for :account
  
  def filter
    filter_to_read = read_attribute(:filter)
    filter_to_read = search.filter if filter_to_read&.empty? && search
    JSON.parse (filter_to_read || {}).to_json, object_class: OpenStruct
  end

end