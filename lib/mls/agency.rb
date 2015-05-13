class Agency < MLS::Model

  belongs_to :listing
  belongs_to :agent, :class_name => 'Account', :inverse_of => :agencies

end
