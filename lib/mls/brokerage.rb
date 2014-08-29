class Brokerage < MLS::Model

  def name
    common_name || proper_name
  end
  
end
