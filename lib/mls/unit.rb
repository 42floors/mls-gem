class Unit < ActiveRecord::Base
  include MLS::Slugger
  include MLS::Avatar

  belongs_to :property

  has_many :listings
  has_many :photos, -> { order('photos.order ASC') }, :as => :subject, :inverse_of => :subject
  
  def tags
    read_attribute(:tags) || []
  end

end
