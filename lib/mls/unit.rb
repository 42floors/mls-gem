class Unit < MLS::Model
  include MLS::Slugger
  include MLS::Avatar

  belongs_to :property
  belongs_to :floorplan

  has_many :listings
  has_many :photos, -> { order('order ASC') }, :as => :subject, :inverse_of => :subject

  has_and_belongs_to_many :uses

  def tags
    read_attribute(:tags) || []
  end

end
