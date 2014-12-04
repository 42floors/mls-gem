class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  belongs_to :contact, :class_name => 'Account'

  has_many :listings
  has_many :localities
  has_many :regions, :through => :localities
  has_many :photos, -> { where(:type => "Photo").order(:order => :asc) }, :as => :subject, :inverse_of => :subject
  has_many :internal_photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  def default_contact
    @default_contact ||= listings.where(lease_state: :listed, ghost: false, authorized: true)
            .where({ type: ['Lease', 'Sublease']})
            .order(size: :desc)
            .first.try(:contact)
  end

end
