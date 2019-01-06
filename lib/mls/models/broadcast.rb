class Broadcast < MLS::Model

  belongs_to :sender, class_name: 'Account'
  
  has_many :emails
  
  has_and_belongs_to_many :regions
  has_and_belongs_to_many :listings
  has_and_belongs_to_many :attachments, class_name: 'Document'
  
end
