class MLS::Attribute::Hash < MLS::Attribute
  
  def load(value) # from_json
    if value.is_a?(Hash)
      value.with_indifferent_access
    else
      value
    end
  end

  def dump(value)
    value
  end

end
