class Task < MLS::Model
  self.inheritance_column = nil

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account
  
  has_many :events
  has_many :mistakes
  has_many :reviews, -> { where(:type => "review") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  has_many :fixes, -> { where(:type => "fix") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  
  def for_source?
    subject_type == "Source"
  end
  
  def for_task?
    subject_type == "Taks"
  end
  
  def review?
    type == "review"
  end
  
  def fix?
    type == "fix"
  end
  
  def perform?
    type == "perform"
  end
  
end
