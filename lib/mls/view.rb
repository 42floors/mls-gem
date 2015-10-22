class View < MLS::Model
  belongs_to :subject, polymorphic: true
end