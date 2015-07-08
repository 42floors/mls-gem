class Property < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_many :units
  has_many :references, as: :subject
  has_many :listings, :through => :units
  has_many :localities
  has_many :regions, :through => :localities
  has_many :image_orderings, as: :subject

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
  
  def closest_region
    region = neighborhood_region
    region ||= city_region
    region ||= market
    region
  end
  
  def neighborhood_region
    params = {:query => neighborhood} if neighborhood
    params = {:type => "Neighborhood"}
    fetch_region(params)
  end
  
  def city_region
    fetch_region(:type => "City")
  end
  
  def market
    fetch_region(:is_market => true)
  end
  
  def target_region
    fetch_region(:target => true)
  end
  
  def fetch_region(params)
    if regions.loaded?
      params = params.map{|k,v| [k, v]}
      if params[0][0] == :query
        regions.to_a.find{|r| r.name == params[0][1]}
      else
        regions.to_a.find{|r| r[params[0][0]] == params[0][1]}
      end
    else
      regions.where(params).first
    end
  end
end
