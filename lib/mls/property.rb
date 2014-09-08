class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  belongs_to :contact, :class_name => 'Account'
  
  has_many :listings
  has_many :localities
  has_many :regions, :through => :localities
  has_many :photos, -> { order('photos.order ASC') }, :as => :subject, :inverse_of => :subject
  # has_many :regions

  has_many   :addresses
  has_one    :address, -> { where(:primary => true) }
  
  def default_contact
    @default_contact ||= listings.where(lease_state: :listed, state: :visible)
            .where({ type: ['Lease', 'Sublease', 'Sale']})
            .order(size: :desc)
            .first.try(:contact)
  end
  
end