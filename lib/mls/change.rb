class Change < MLS::Model
  self.inheritance_column = nil
  
  belongs_to :subject, :polymorphic => true
  has_many :event_actions, :as => :action
  
end
