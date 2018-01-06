class Team < MLS::Model
  
  has_and_belongs_to_many :accounts
  belongs_to :organization
  
end
