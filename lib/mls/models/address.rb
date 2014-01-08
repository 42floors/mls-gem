class MLS::Address < MLS::Resource

  property :id,           Fixnum,   :serialize => :false
  property :property_id,  Fixnum,   :serialize => :false
  property :slug,         String,   :serialize => :false
  
  property :formatted_address, String
  property :street_number, String
  property :street, String
  property :neighborhood, String
  property :city, String
  property :county, String
  property :state, String
  property :country, String
  property :postal_code, String
  
  attr_accessor :property
  
  def save
    MLS.put("/addresses/#{id}", {:address => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLS::Address::Parser.update(self, response.body)
        code == 200      
      else
        raise MLS::Exception::UnexpectedResponse, code
      end
    end
  end

  def to_param
    slug
  end

  class << self

    def find(id)
      response = MLS.get("/addresses/#{id}")
      MLS::Address::Parser.parse(response.body)
    end

    # currently supported options are :include, :where, :limit, :offset
    def all(options={})
      response = MLS.get('/addresses', options)
      MLS::Address::Parser.parse_collection(response.body)
    end

  end
  
end


class MLS::Address::Parser < MLS::Parser
  
  def property=(property)
    @object.property = MLS::Property::Parser.build(property)
  end
  
end
