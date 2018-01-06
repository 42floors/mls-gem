class ImageOrdering < MLS::Model
  
  belongs_to :subject, :polymorphic => true
  belongs_to :image
  
end
