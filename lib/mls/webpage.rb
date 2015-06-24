class Webpage < MLS::Model

  has_one :task, as: :subject

  validates :url, presence: true

end
