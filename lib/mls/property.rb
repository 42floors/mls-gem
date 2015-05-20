class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_many :units
  has_many :references, as: :subject
  has_many :listings, :through => :units
  has_many :localities
  has_many :regions, :through => :localities
  has_many :image_orderings, as: :subject, dependent: :destroy

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  def photos
    image_orderings.sort_by(&:order).map(&:image)
  end

  def contact
    @contact ||= listings.where(leased_at: nil, authorized: true, type: ['Lease', 'Sublease'])
            .order(size: :desc).first.try(:contact)
  end

  def address
    addresses.find(&:primary)
  end

end
