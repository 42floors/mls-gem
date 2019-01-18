class Integrations::Buildout < MLS::Model
  def self.table_name_prefix
    'integrations/buildout/'
  end

  has_many :syndications
end

require 'mls/models/integrations/buildout/syndication'
