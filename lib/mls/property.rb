class Property < MLS::Model

  include MLS::Slugger
  
  belongs_to :avatar, :class_name => 'Photo'
  belongs_to :contact, :class_name => 'Account'
  
  has_many :listings
  has_many :localities
  has_many :regions, :through => :localities
  has_many :photos, -> { order('photos.order ASC') }, :as => :subject, :inverse_of => :subject
  # has_many :regions

  has_many   :addresses
  has_one    :address, -> { where(:primary => true) }
  
  # TODO: move to avatar module to share with other models
  def avatar_url(options={})
    options.reverse_merge!({
      :style => nil,
      :protocol => "http",
      :bg => nil,
      :format => "jpg"
    });
    url_params = {s: options[:style], bg: options[:bg]}.select{ |k, v| v }
    result = "#{options[:protocol]}://#{MLS.image_host}/#{avatar_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 1

    result
  end
  
  def default_contact
    @default_contact ||= listings.where(lease_state: :listed, state: :visible)
            .where({ type: ['Lease', 'Sublease', 'Sale']})
            .order(size: :desc)
            .first.try(:contact)
  end
  
end