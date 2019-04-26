class Testfit < MLS::Model
  self.inheritance_column = nil
  
  belongs_to :listing
  belongs_to :document
  
end
