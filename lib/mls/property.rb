class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  LEED_CERTIFICATIONS = %w(None Certified Silver Gold Platinum)
  AMENITIES = %W(parking_garage lobby_attendant gym common_kitchen
    common_bike_storage onsite_parking key_card_access freight_elevator
    ada_accessible on_site_security
    elevators close_highway close_public_transit close_points_of_interest
    parking_ratio number_of_buildings)
  CONSTRUCTION_TYPES = %w(brick steel concrete masonry tiltwall wood glass)

  has_many :units
  has_many :references, as: :subject
  has_many :listings
  has_many :localities
  has_many :regions, :through => :localities
  has_many :image_orderings, as: :subject
  has_many :data, as: :subject
  has_many :photos, through: :image_orderings, source: :image

  has_many :uses
  # has_and_belongs_to_many :uses

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  accepts_nested_attributes_for :photos, :image_orderings

  def photos_attributes=(attrs)
    attrs ||= []

    self.photos = attrs.each_with_index.map do |photo_attrs, index|
        photo = Image.find(photo_attrs.delete(:id))
        photo.update(photo_attrs) unless photo_attrs.empty?
        photo
    end
  end

  def photos=(array)
    array.compact!
    return if self.photos.map(&:id) == array.map(&:id)

    self.photos.clear
    super
  end

  def contacts
    @contact ||= listings.eager_load(:agents => [:email_addresses, :phones, :organization]).where(leased_at: nil, authorized: true, type: ['Lease', 'Sublease'], :touched_at => {:gte => 90.days.ago})
            .order(size: :desc).first.try(:contacts)
  end

  def address
    addresses.find(&:primary)
  end

  def longitude
    location.x
  end

  def latitude
    location.y
  end

  def automated_description
    description_narrativescience
  end

  def display_description
    return description if description.present?
    # If has bullets
    if description_data_entry && description_data_entry.split("\n").all? { |x| ['-','*', '•'].include?(x.strip[0]) }
      <<~MD
      #{description_narrativescience}
      ##Features
      #{description_data_entry}
      MD
    elsif description_data_entry
      show_amenities = amenities.select{ |k,v| v }
      <<~MD
      #{description_narrativescience}
      #{description_data_entry}
      #{"This building's amenities include " + show_amenities.map {|key, v| key.to_s.humanize.downcase }.to_sentence + "."}
      MD
    else
      description_narrativescience
    end
  end

  def internet_providers
    idata = []
    
    datum = data.select{|d| d.source == "broadbandmap.gov"}.first.try(:datum) if data.loaded?
    datum ||= data.where(source: 'broadbandmap.gov').first.try(:datum)
    return idata unless datum && datum['wirelineServices']

    datum['wirelineServices'].sort_by{|p| p['technologies'].sort_by{|t| t['maximumAdvertisedDownloadSpeed']}.reverse.first['maximumAdvertisedDownloadSpeed']}.reverse.each do |provider|
       tech = provider['technologies'].sort_by{|t| t['maximumAdvertisedDownloadSpeed']}.reverse.first
       speedcase = -> (speedCode) {
         case speedCode
         when 1 then '200 kbps'
         when 2 then '768 kbps'
         when 3 then '1.5 Mb/s'
         when 4 then '3 Mb/s'
         when 5 then '6 Mb/s'
         when 6 then '10 Mb/s'
         when 7 then '25 Mb/s'
         when 8 then '50 Mb/s'
         when 9 then '100 Mb/s'
         when 10 then '1 Gb/s'
         when 11 then '1 Gb/s+'
         else 'Unknown'
         end
       }

       idata << {
         provider_name: provider['doingBusinessAs'] || provider['providerName'],
         provider_url: provider['providerURL'],
         technology: case tech['technologyCode']
           when 10 then 'DSL'
           when 20 then 'DSL'
           when 30 then 'Copper Wireline'
           when 40 then 'Cable'
           when 41 then 'Cable'
           when 50 then 'Fiber'
           when 90 then 'Power Line'
           else 'Other'
           end,
         bandwidth: {
           up: speedcase.call(tech['maximumAdvertisedUploadSpeed']),
           down: speedcase.call(tech['maximumAdvertisedDownloadSpeed'])
         }
       }
    end

    idata
  end

  def closest_region
    region = neighborhood_region
    region ||= city_region
    region ||= market
    region
  end

  def neighborhood_region
    return @neighborhood_region if defined? @neighborhood_region
    params = {:query => neighborhood} if neighborhood
    params ||= {:type => "Neighborhood"}
    @neighborhood_region = fetch_region(params)
  end

  def city_region
    return @city_region if defined? @city_region
    @city_region = fetch_region(:type => "City")
  end

  def market
    return @market if defined? @market
    @market = fetch_region(:is_market => true)
  end

  def flagship
    return @flagship if defined? @flagship
    @flagship = fetch_region(:is_flagship => true)
  end

  def fetch_region(params)
    params = params.map{|k,v| [k, v]}
    if params[0][0] == :query
      regions.to_a.find{|r| r.name == params[0][1]}
    else
      regions.to_a.find{|r| r[params[0][0]] == params[0][1]}
    end
  end
end
