class MLSGem::Address < MLSGem::Resource

  attribute :id,           Fixnum,   :serialize => :false
  attribute :property_id,  Fixnum,   :serialize => :false
  attribute :slug,         String,   :serialize => :false
  
  attribute :formatted_address, String
  attribute :street_number, String
  attribute :street, String
  attribute :neighborhood, String
  attribute :city, String
  attribute :county, String
  attribute :state, String
  attribute :country, String
  attribute :postal_code, String
  
  attr_accessor :property
  
  def save
    MLSGem.put("/addresses/#{id}", {:address => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLSGem::Address::Parser.update(self, response.body)
        code == 200      
      else
        raise MLSGem::Exception::UnexpectedResponse, code
      end
    end
  end

  def to_param
    slug
  end

  class << self

    def find(id)
      response = MLSGem.get("/addresses/#{id}")
      MLSGem::Address::Parser.parse(response.body)
    end

    # currently supported options are :include, :where, :limit, :offset
    def all(options={})
      response = MLSGem.get('/addresses', options)
      MLSGem::Address::Parser.parse_collection(response.body)
    end

  end
  
end


class MLSGem::Address::Parser < MLSGem::Parser
  
  def property=(property)
    @object.property = MLSGem::Property::Parser.build(property)
  end
  
end
