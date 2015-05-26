class Vendor < MLS::Model
  self.inheritance_column = nil

  include MLS::Slugger
  include MLS::Avatar

  has_and_belongs_to_many :regions
  belongs_to :account
  has_many :photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

end
