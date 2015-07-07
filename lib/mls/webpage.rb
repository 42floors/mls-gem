class Webpage < MLS::Model

  has_many :tasks, as: :subject

  validates :url, presence: true

end
