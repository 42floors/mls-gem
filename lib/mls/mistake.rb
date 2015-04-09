class Mistake < MLS::Model
  self.inheritance_column = false
  
  TYPES = %w(missing spelling incorrect other)
  
  belongs_to :task
  belongs_to :change
  belongs_to :account
  
end
