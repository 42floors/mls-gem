class Agency < MLS::Model

  belongs_to :subject, polymorphic: true
  belongs_to :agent, :class_name => 'Account', :inverse_of => :agencies

end
