class Task < MLS::Model

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account

end
