class Organization < MLS::Model
  include MLS::Avatar
  include MLS::Slugger
  
  has_many :agents, :class_name => 'Account'
  has_and_belongs_to_many :regions
  
  def name
    common_name || legal_name
  end

end
