class LeadListing < MLS::Model

  belongs_to :listing
  belongs_to :lead
  belongs_to :property

  has_many :comments, :as => :subject

end
