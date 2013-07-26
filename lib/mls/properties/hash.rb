class MLS::Property::Hash < MLS::Property
  
  def load(value) # from_json
    value.with_indifferent_access
  end

end
