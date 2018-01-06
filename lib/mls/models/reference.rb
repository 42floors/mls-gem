class Reference < MLS::Model
  self.inheritance_column = nil

  belongs_to :subject, polymorphic: true

  validates :type, presence: true

end

