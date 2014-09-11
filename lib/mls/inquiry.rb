class Inquiry < MLS::Model

  belongs_to :lead
  belongs_to :subject, polymorphic: true

end
