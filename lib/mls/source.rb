class Source < MLS::Model

  has_many :tasks, :as => :subject
  has_many :emails
  has_many :email_addresses
  has_many :webpages, :inverse_of => :source
  
  has_and_belongs_to_many :regions
  
  belongs_to :account
  belongs_to :organization
  belongs_to :upload, class_name: 'Flyer'
  
  def name
    domain
  end
  
end
