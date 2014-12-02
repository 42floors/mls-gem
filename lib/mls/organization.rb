class Organization < MLS::Model
  include MLS::Avatar
  include MLS::Slugger
  
  has_many :agents, :class_name => 'Account'
  
  def name
    common_name || legal_name
  end

end
