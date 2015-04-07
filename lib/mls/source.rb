class Source < MLS::Model

  has_many :tasks, :as => :subject
  
  belongs_to :account
  belongs_to :upload, class_name: 'Flyer'
  
  def name
    url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/]+)/)[1]
  end
  
end
