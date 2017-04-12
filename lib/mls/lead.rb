class Lead < MLS::Model

  has_many  :inquiries
  has_many  :tim_alerts

end
