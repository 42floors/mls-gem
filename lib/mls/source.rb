class Source < MLS::Model

  has_many :tasks_for, :as => :subject, :inverse_of => :subject, :class_name => 'Task'
  
  belongs_to :owner, class_name: 'Account'
  belongs_to :upload, class_name: 'Flyer'
  
end
