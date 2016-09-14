class Organization < MLS::Model
  include MLS::Avatar
  include MLS::Slugger
  
  has_many :accounts, :class_name => 'Account'
  has_many :listings, -> { distinct }, through: :accounts
  has_and_belongs_to_many :regions
  
  def name
    common_name || legal_name
  end

end
