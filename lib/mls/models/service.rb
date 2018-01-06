class Service < MLS::Model
  self.inheritance_column = nil

  belongs_to :subscription
  belongs_to :subject, polymorphic: true

  def name
    self.type.humanize
  end
  
end