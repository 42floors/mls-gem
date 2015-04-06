class Task < MLS::Model

  belongs_to  :subject, :polymorphic => true
  belongs_to  :assigned_to, class_name: "Account"

end
