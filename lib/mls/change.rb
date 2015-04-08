class Change < MLS::Model
  
  belongs_to :subject, :polymorphic => true
  has_many :event_actions, :as => :action
  
end
