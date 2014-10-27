class Region < MLS::Model
  
  include MLS::Slugger
  
  self.inheritance_column = nil

  belongs_to :cover_photo, :class_name => 'Photo'
    
  has_and_belongs_to_many :parents, :join_table => 'regions_regions', :class_name => 'Region', :foreign_key => 'child_id', :association_foreign_key => 'parent_id'
  has_and_belongs_to_many :children, :join_table => 'regions_regions', :class_name => 'Region', :foreign_key => 'parent_id', :association_foreign_key => 'child_id'
  
  
end