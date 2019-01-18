class Integrations::Buildout::Syndication < MLS::Model
  self.table_name = "integrations/buildout/syndications"

  belongs_to :buildout
  has_many :tasks, as: :subject, inverse_of: :subject

end
