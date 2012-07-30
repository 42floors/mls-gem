class MLS::Property::DateTime < MLS::Property
  
  def load(value) # from_json
    if value.is_a?(::String)
      ::DateTime.iso8601(value)
    elsif value.nil? || value.is_a?(::DateTime)
      value
    elsif value.is_a?(::Time) || value.is_a?(::Date)
      value.to_datetime
    else
      raise 'unsupported date type'
    end
  end
  
  def dump(value)
    if value.is_a?(::DateTime) || value.is_a?(::Time) || value.is_a?(::Date)
      value.iso8601
    elsif value.nil?
      nil
    else
      raise 'unsupported date type'
    end
  end

end
