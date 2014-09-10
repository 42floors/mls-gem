class Organization < MLS::Model
  include MLS::Avatar

  def name
    common_name || legal_name
  end

end
