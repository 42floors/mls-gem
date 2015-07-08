class Geometry < MLS::Model
  
  self.inheritance_column = nil

  belongs_to :subject, polymorphic: true

end
