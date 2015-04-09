class Task < MLS::Model

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account
  
  has_many :events
  has_many :mistakes
  
  def for_source?
    subject_type == "Source"
  end
  
  def for_task?
    subject_type == "Taks"
  end
  
end
