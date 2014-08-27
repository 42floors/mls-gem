class Property < MLS::Model

  belongs_to :avatar, :class_name => 'Photo'
  
  has_many :listings

  has_many   :addresses
  has_one    :address, -> { where(:primary => true) }
  
end