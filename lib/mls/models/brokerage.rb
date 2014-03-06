class MLSGem::Brokerage < MLSGem::Resource

  attr_accessor :avatar

  attribute :id,       Fixnum,  :serialize => :if_present
  attribute :name,     String,  :serialize => :if_present
  attribute :admin_id, Fixnum,  :serialize => :if_present
  attribute :slug,     String,  :serialize => false
  attribute :palette,  Hash,    :serialize => :if_present

  class << self

    def find(id)
      response = MLSGem.get("/brokerages/#{id}")
      MLSGem::Brokerage::Parser.parse(response.body)
    end

    def all(options={})
      response = MLSGem.get('/brokerages', options)
      MLSGem::Brokerage::Parser.parse_collection(response.body)
    end

  end

end

class MLSGem::Brokerage::Parser < MLSGem::Parser
  def avatar=(avatar)
    @object.avatar = MLSGem::Photo::Parser.build(avatar)
  end
end