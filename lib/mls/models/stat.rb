class Stat < MLS::Model
  belongs_to :subject, polymorphic: true
end