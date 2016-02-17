class Inquiry < MLS::Model

  has_many :emails
  belongs_to :lead
  belongs_to :subject, polymorphic: true
  belongs_to :account

  def property
    subject.is_a? MLS::Model::Listing ? subject.property : subject
  end

end
