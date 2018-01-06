class EmailAddress < MLS::Model
  self.inheritance_column = false
  
  TYPES = %w(work personal other)
  
  has_many :emails
  
  belongs_to :account

  def name
    address
  end
end
