class TimAlert < MLS::Model
  self.inheritance_column = nil

  belongs_to  :account
  belongs_to  :lead

end
