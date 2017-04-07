class Metadatum < MLS::Model
  has_many :actions, foreign_key: :event_id, primary_key: :event_id
end
