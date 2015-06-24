class Source < MLS::Model

  has_many :tasks, :as => :subject
  has_many :emails
  
  belongs_to :account
  belongs_to :organization
  belongs_to :upload, class_name: 'Flyer'
  
  def name
    return email_address if email_address.present?
    url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/]+)/)[1]
  end
  
end
