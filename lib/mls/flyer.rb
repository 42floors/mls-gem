class Flyer < MLS::Model
  
  belongs_to :account
  belongs_to :listing
  
  def fields
    read_attribute(:fields).with_indifferent_access
  end
  
end
