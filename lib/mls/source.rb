class Source < MLS::Model

  has_many :tasks, :as => :subject
  
  belongs_to :account
  belongs_to :organization
  belongs_to :upload, class_name: 'Flyer'
  
  def name
    # return email_address if email_address.defined? && email_address #check defined while project mailman not released
    url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/]+)/)[1]
  end
  
end
