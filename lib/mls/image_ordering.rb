class ImageOrdering < MLS::Model
  
  belongs_to :subject, :counter_cache => :photos_count, :polymorphic => true
  belongs_to :image
  
end
