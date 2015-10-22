class Webpage < MLS::Model

  belongs_to :source
  has_many :tasks, as: :subject

  validates :url, presence: true

  def name
    url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/]+)/)[1]
  end

end
