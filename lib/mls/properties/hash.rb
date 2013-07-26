class MLS::Property::Hash < MLS::Property
  
  def load(value) # from_json
    case value
    when Hash
      value.with_indifferent_access
    else
      value
    end
  end

  def dump(value)
    value
  end

end
