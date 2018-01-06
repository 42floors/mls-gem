class Flyer < MLS::Model
  
  belongs_to :account
  belongs_to :listing
  belongs_to :document
  
  def fields
    read_attribute(:fields).with_indifferent_access
  end
  
end
