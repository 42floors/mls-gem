class Site < MLS::Model
  
  belongs_to :region
  belongs_to :cover_photo, :class_name => 'Image'
  belongs_to :logo, :class_name => 'Image'

  has_many :ownerships, as: :asset
  has_many :accounts, through: :ownerships, source: :account, inverse_of: :sites

  def contacts
    if ownerships.loaded?
      @contacts ||= ownerships.select{|o| o.receives_inquiries }.map(&:account)
    else
      @contacts ||= ownerships.eager_load(:account).filter(:receives_inquiries => true).map(&:account)
    end
  end

  def lead_contacts
    if ownerships.loaded?
      @lead_contacts ||= ownerships.select{|o| o.lead}.map(&:account)
    else
      @lead_contacts ||= ownerships.eager_load(:account).filter(:lead => true).map(&:account)
    end
  end
end
