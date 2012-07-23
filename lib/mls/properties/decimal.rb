class MLS::Property::Decimal < MLS::Property
  
  def load(value) # from_json
    if value.is_a?(BigDecimal)
      value
    else
      BigDecimal.new(value.to_s)
    end
  end
  
  def dump(value)
    if value.is_a?(BigDecimal)
      value.to_s
    else
      value
    end
  end

end
