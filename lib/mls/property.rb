class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_many :units
  has_many :references, as: :subject
  has_many :listings
  has_many :localities
  has_many :regions, :through => :localities
  has_many :image_orderings, as: :subject
  has_many :photos, through: :image_orderings, source: :image

  has_many   :addresses do
    def primary
      where(:primary => true).first
    end
  end

  def contact
    @contact ||= listings.eager_load(:email_addresses, :phones).where(leased_at: nil, authorized: true, type: ['Lease', 'Sublease'])
            .order(size: :desc).first.try(:contact)
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
    external_data['narrativescience.com']
  end
  
  def internet_providers
    data = []
    
    if external_data['broadbandmap.gov']
      if external_data['broadbandmap.gov']['wirelineServices']
        external_data['broadbandmap.gov']['wirelineServices'].sort_by{|p| p['technologies'].sort_by{|t| t['maximumAdvertisedDownloadSpeed']}.reverse.first['maximumAdvertisedDownloadSpeed']}.reverse.each do |provider|
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

           data << {
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
      end
    end

    data
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
    params = {:type => "Neighborhood"}
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
