class MLS::Tour < MLS::Resource
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
    MLS.post("/tours/#{token}/decline", {:agent_comments => notes})
  end

  def declined?
    declined
  end

  class << self
    def get_all_for_account
      response = MLS.get('/account/tours')
      MLS::Tour::Parser.parse_collection(response.body)
    end

    def find_by_token(token)
      response = MLS.get("/tours/#{token}")
      MLS::Tour::Parser.parse(response.body)
    end

    def create(listing_id, account, tour={})
      params = {:account => account, :tour => tour}
      response = MLS.post("/listings/#{listing_id}/tour", params)
      return MLS::Tour::Parser.parse(response.body)
    end
  end

end

class MLS::Tour::Parser < MLS::Parser
  
  def listing=(listing)
    @object.listing = MLS::Listing::Parser.build(listing)
  end
  
  def client=(account)
    @object.client = MLS::Account::Parser.build(account)
  end

end
