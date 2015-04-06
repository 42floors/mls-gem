class Task < MLS::Model

  belongs_to  :subject, :polymorphic => true, :inverse_of => :tasks_for
  belongs_to  :assigned_to, class_name: "Account"

end
