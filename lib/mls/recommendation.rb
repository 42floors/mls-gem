class Recommendation < MLS::Model

  belongs_to :listing
  belongs_to :lead

  has_many :comments, :as => :subject

end
