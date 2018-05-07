class Review < MLS::Model
  
  belongs_to :document
  belongs_to :account
  
  def approved?
    approval == true
  end
  
  def rejected?
    approval == false
  end
  
  def pending?
    approval == nil
  end

end