class MLS::Brokerage < MLS::Resource

  attr_accessor :avatar

  attribute :id,       Fixnum,  :serialize => :if_present
  attribute :name,     String,  :serialize => :if_present
  attribute :admin_id, Fixnum,  :serialize => :if_present
  attribute :slug,     String,  :serialize => false
  attribute :palette,  Hash,    :serialize => :if_present
  attribute :avatar_digest, String,   :serialize => false

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
  def avatar=(avatar)
    @object.avatar = MLS::Photo::Parser.build(avatar)
  end
end