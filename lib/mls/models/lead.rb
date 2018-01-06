class Lead < MLS::Model

  STATUSES = %w(delivered connected touring proposals leases closed lost)
  
  has_many  :inquiries
  has_many  :tim_alerts
  
  def regions
    Region.where(id: region_ids)
  end
  
  def term_units(value=nil)
    value ||= self.term
    case value
    when "<1"
      "year"
    when "flexible"
      ""
    when nil
      ""
    else
      "years"
    end
  end

end
