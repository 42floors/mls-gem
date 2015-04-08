class Task < MLS::Model

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account
  
  has_many :events

end
