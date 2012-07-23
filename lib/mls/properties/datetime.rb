class MLS::Property::DateTime < MLS::Property
  
  def load(value) # from_json
    if value.is_a?(::String)
      ::DateTime.iso8601(value)
    elsif value.nil? || value.is_a?(::DateTime)
      value
    else
      raise 'unsupported date type'
    end
  end
  
  def dump(value)
    if value.is_a?(::DateTime)
      value.iso8601
    else
      raise 'unsupported date type'
    end
  end

end
