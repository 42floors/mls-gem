class MLSGem::Tour < MLSGem::Resource
  attribute :id,                           Fixnum
  attribute :declined,                     Boolean
  attribute :client_id,                    Fixnum
  attribute :agent_id,                     Fixnum
  attribute :listing_id,                   Fixnum
  attribute :comments,                     String
  attribute :agent_comments,               String,    :serialize => :if_present
  attribute :token,                        String,    :serialize => :false
  attribute :created_at,                   DateTime,  :serialize => :false
  attribute :updated_at,                   DateTime,  :serialize => :false

  attr_accessor :client, :listing

  def decline(notes=nil)
    self.agent_comments = notes
    MLSGem.post("/tours/#{token}/decline", {:agent_comments => notes})
  end

  def declined?
    declined
  end

  class << self
    def get_all_for_account
      response = MLSGem.get('/account/tours')
      MLSGem::Tour::Parser.parse_collection(response.body)
    end

    def find_by_token(token)
      response = MLSGem.get("/tours/#{token}")
      MLSGem::Tour::Parser.parse(response.body)
    end

    def create(listing_id, account, tour={})
      params = {:account => account, :tour => tour}
      response = MLSGem.post("/listings/#{listing_id}/tour", params)
      return MLSGem::Tour::Parser.parse(response.body)
    end
  end

end

class MLSGem::Tour::Parser < MLSGem::Parser
  
  def listing=(listing)
    @object.listing = MLSGem::Listing::Parser.build(listing)
  end
  
  def client=(account)
    @object.client = MLSGem::Account::Parser.build(account)
  end

end
