class Action < MLS::Model
  self.inheritance_column = nil
  
  belongs_to :event
  belongs_to :subject, :polymorphic => true
  
  has_many :mistakes
  
end
