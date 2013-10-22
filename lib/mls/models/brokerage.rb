class MLS::Brokerage < MLS::Resource

  property :id,       Fixnum,  :serialize => :if_present
  property :name,     String,  :serialize => :if_present
  property :admin_id, Fixnum,  :serialize => :if_present
  property :slug,     String,  :serialize => false
  property :palette,  Hash,    :serialize => :if_present
  property :avatar_digest, String,   :serialize => false

  class << self

    def find(id)
      response = MLS.get("/brokerages/#{id}")
      MLS::Brokerage::Parser.parse(response.body)
    end

    def all(options={})
      response = MLS.get('/brokerages', options)
      MLS::Brokerage::Parser.parse_collection(response.body)
    end

  end

end

class MLS::Brokerage::Parser < MLS::Parser
end