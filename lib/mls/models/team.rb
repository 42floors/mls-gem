class Team < MLS::Model

  belongs_to :organization
  has_and_belongs_to_many :accounts
  has_many :tasks

end
