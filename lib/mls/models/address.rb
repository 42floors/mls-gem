class MLS::Address < MLS::Resource

  property :id, Fixnum,   :serialize => :if_present
  property :name, String, :serialize => :false
  property :slug, String,   :serialize => :if_present
  
  property :latitude, Decimal
  property :longitude, Decimal
  
  property :formatted_address, String
  property :street_number, String
  property :street, String
  property :neighborhood, String
  property :city, String
  property :county, String
  property :state, String
  property :country, String
  property :postal_code, String

  class << self
    
    def query(q)
      response = MLS.get('/addresses/query', :query => q)
      MLS::Address::Parser.parse_collection(response.body)
    end

    # Bounds is passed as 'n,e,s,w' or [n, e, s, w]
    def box_cluster(bounds, zoom, filters={})
      response = MLS.get('/addresses/box_cluster', :bounds => bounds, :zoom => zoom, :filters => filters)
    end
    
  end
  
end


class MLS::Address::Parser < MLS::Parser
  
end
