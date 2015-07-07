class Space < MLS::Model

  belongs_to  :coworking_space
  has_many    :image_orderings, as: :subject, dependent: :destroy
  has_many    :photos, through: :image_orderings, source: :image

end
