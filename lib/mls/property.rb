class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_many :units
  has_many :references, as: :subject
  has_many :listings, :through => :units
  has_many :localities
  has_many :regions, :through => :localities
  has_many :photos, -> { where(:type => "Photo").order(:order => :asc) }, :as => :subject, :inverse_of => :subject
  has_many :internal_photos, -> { order(:order => :asc) }, :as => :subject, :inverse_of => :subject

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  def contact
    @contact ||= listings.where(leased_at: nil, authorized: true, type: ['Lease', 'Sublease']})
            .order(size: :desc).first.try(:contact)
  end

  def address
    addresses.find(&:primary)
  end
  
  def internal_avatar_url(options={}) 
    options.reverse_merge!({
      :style => nil,
      :bg => nil,
      :protocol => 'https',
      :format => "jpg",
      :host => MLS.image_host
    });

    url_params = { s: options[:style], bg: options[:bg] }.select{ |k, v| v }

    if options[:protocol] == :relative # Protocol Relative
      result = '//'
    else options[:protocol]
      result = "#{options[:protocol]}://"
    end
    
    result += "#{options[:host]}/#{internal_avatar_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end
