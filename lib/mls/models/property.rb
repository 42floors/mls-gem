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

  has_many :references, as: :subject
  has_many :listings
  has_many :localities
  has_many :coworking_spaces
  has_many :regions, :through => :localities
  has_many :image_orderings, as: :subject
  has_many :data, as: :subject
  has_many :photos, through: :image_orderings, source: :image
  has_many :services, as: :subject

  has_many :uses
  # has_and_belongs_to_many :uses

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  accepts_nested_attributes_for :image_orderings, :addresses

  def contacts
    @contact ||= listings.eager_load(:accounts => [:email_addresses, :phones, :organization]).filter(leased_at: nil, authorized: true, type: ['Lease', 'Sublease'], :touched_at => {:gte => 180.days.ago})
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
  
  def is_elite_for_account_ids?(*account_ids)
    return false unless self.elite_account_ids && self.elite_account_ids.length > 0
    account_ids = Array(account_ids).flatten
    (self.elite_account_ids & account_ids).length > 0
  end

  def display_description
    return description if description.present?
    return unless description_data_entry
    # If has bullets
    if description_data_entry && description_data_entry.split("\n").all? { |x| ['-','*', '•'].include?(x.strip[0]) }
      <<~MD
      ##Features
      #{description_data_entry}
      MD
    else description_data_entry
      show_amenities = amenities.select{ |k,v| v }
      <<~MD
      #{description_data_entry}
      #{"This building's amenities include " + show_amenities.map {|key, v| key.to_s.humanize.downcase }.to_sentence + "."}
      MD
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
         when 11 then '10 Gb/s'
         when 12 then '100 Gb/s'
         when 13 then '100 Gb/s+'
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
    region ||= regions.filter(depth: true).select{ |r| r.type != "Zip Code Tabulation Area" }.sort_by(&:depth).reverse.first
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
    @city_region = fetch_region(:type => Region::CITY_TYPES)
  end
  
  def state_region
    return @state_region if defined? @state_region
    @state_region = fetch_region(:type => Region::STATE_TYPES)
  end

  def market
    return @market if defined? @market
    @market = fetch_region(:is_market => true)
  end
  
  def human_breadcrumbs
    [
      neighborhood.present? ? neighborhood : neighborhood_region&.name,
      city.present? ? city : (city_region&.name || regions.select{|r|
        r.depth && r.depth >= 3
      }.first&.name),
      state.present? ? state : state_region&.slug&.split("/")&.last&.upcase
    ].compact
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
      regions.to_a.find{|r|
        if params[0][1].is_a? Array
          params[0][1].include? (r[params[0][0]])
        else
          r[params[0][0]] == params[0][1]
        end
      }
    end
  end
end
