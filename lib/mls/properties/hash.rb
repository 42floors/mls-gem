class MLS::Property::Hash < MLS::Property
  
  def load(value) # from_json
    value && value.with_indifferent_access
  end

  def dump(value)
    value
  end

end
