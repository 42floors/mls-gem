class MLS::Listing < MLS::Resource

  LEASES = ['Full Service', 'NNN', 'Gross', 'Industrial Gross', 'Modified Gross']

  # validates :use, :presence => true
  # validates :property, :presence => true
  # validates :address, :presence => true, :inclusion => { :in => lambda { |l| l.property.try(:addresses).to_a } }
  validates :total_size, :presence => true, :numericality => true
  validates :maximum_contiguous_size, :presence => true, :numericality => true
  validates :minimum_divisable_size, :presence => true, :numericality => true
  validates :lease, :inclusion => {:in => LEASES, :allow_nil => true, :allow_blank => true}
  validates :asking_rate, :numericality => { :allow_nil => true }
  validates :sublease_expiration, :presence => { :if => proc { |l| l.sublease? }}
  validates :nnn_expenses, :presence => { :if => proc { |l| l.lease == 'NNN' }}, :numericality => { :allow_nil => true }
  validates :available_on, :presence => true
  validates :floor, :numericality => { :allow_nil => true }
  validates :offices, :numericality => { :allow_nil => true }
  validates :conference_rooms, :numericality => { :allow_nil => true }
  validates :bathrooms, :numericality => { :allow_nil => true }
  validates :showers, :numericality => { :allow_nil => true }
  validates :maximum_rate, :numericality => { :allow_nil => true }
  validates :minimum_rate, :numericality => { :allow_nil => true }
  validates :maximum_term_length, :numericality => { :allow_nil => true, :only_integer => true }
  validates :minimum_term_length, :numericality => { :allow_nil => true, :only_integer => true }
  validates :kind, :presence => true, :inclusion => {:in => ['unit', 'floor', 'building']}
  validates :rate_units, :presence => true, :inclusion => { :in => ['ft^2/year', 'ft^2/month'] }

  def property
    attributes['property'] ||= MLS::Property.find(property_id)
  end
  
  schema do
    # attribute :use, :string
    attribute :total_size, :integer
    attribute :sublease, :boolean
    attribute :maximum_contiguous_size, :integer
    attribute :minimum_divisable_size, :integer
    attribute :available_on, :date
    attribute :unit, :string
    attribute :lease, :string
    attribute :asking_rate, :decimal, :precision => 8,  :scale => 2
    attribute :sublease_expiration, :date
    attribute :nnn_expenses, :decimal
    attribute :floor, :integer
    attribute :tenant_improvement, :string
    attribute :commnets, :text
    attribute :kitchen, :boolean, :default => false
    attribute :offices, :integer
    attribute :conference_rooms, :integer
    attribute :bathrooms, :integer
    attribute :showers, :boolean, :default => false
    attribute :bike_rake, :boolean, :default => false
    attribute :server_room, :boolean, :default => false
    attribute :reception_area, :boolean, :default => false
    attribute :turnkey, :boolean, :default => false
    attribute :patio, :boolean, :default => false
    attribute :created_at, :datetime
    attribute :updated_at, :datetime
    attribute :deleted_at, :datetime
    attribute :copy_room, :boolean
    attribute :term_length, :integer
    attribute :bikes_allowed, :boolean
    attribute :dog_friendly, :boolean
    attribute :furniture_available, :boolean
    attribute :cabling, :boolean
    attribute :ready_to_move_in, :boolean
    attribute :recent_space_improvements, :boolean
    attribute :maximum_term_length, :integer
    attribute :minimum_term_length, :integer
    attribute :minimum_rate, :decimal, :precision => 8,  :scale => 2
    attribute :maximum_rate, :decimal, :precision => 8,  :scale => 2
    attribute :kind, :string
    attribute :rate_units, :string
  end

  def available_on
    Date.parse(attributes[:available_on])
  end

  def sublease_expiration
    Date.parse(attributes[:sublease_expiration])
  end

end
