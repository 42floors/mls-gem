class Source < MLS::Model

  has_many :tasks, :as => :subject
  
  belongs_to :owner, class_name: 'Account'
  belongs_to :upload, class_name: 'Flyer'
  
end
