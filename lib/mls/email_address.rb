class EmailAddress < MLS::Model
  self.inheritance_column = false
  
  TYPES = %w(work personal other)
  
  belongs_to :account

end
