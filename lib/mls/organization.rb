class Organization < MLS::Model

  def name
    common_name || legal_name
  end

end
