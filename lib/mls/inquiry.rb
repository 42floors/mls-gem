class Inquiry < MLS::Model

  belongs_to :lead
  belongs_to :subject, polymorphic: true

  def property
    subject.is_a? MLS::Model::Listing ? subject.property : subject
  end

end
