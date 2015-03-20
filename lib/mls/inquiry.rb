class Inquiry < MLS::Model

  belongs_to :lead
  belongs_to :subject, polymorphic: true

  def property
    subject.is_a? Listing ? subject.property : subject
  end

end
