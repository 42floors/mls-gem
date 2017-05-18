class Lead < MLS::Model

  STATUSES = %w(delivered connected touring proposals leases closed lost)
  
  has_many  :inquiries
  has_many  :tim_alerts
  
  def regions
    Region.where(id: region_ids)
  end

end
