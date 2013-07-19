class MLS::Contact < MLS::Resource
  property :id,                           Fixnum
  property :status,                       String
  property :client_id,                    Fixnum
  property :agent_id,                     Fixnum
  property :listing_id,                   Fixnum
  property :comments,                     String
  property :agent_comments,               String,    :serialize => :if_present
  property :token,                        String,    :serialize => :false
  property :created_at,                   DateTime,  :serialize => :false
  property :updated_at,                   DateTime,  :serialize => :false

  attr_accessor :client, :listing

  def claim(agent)
    self.agent_id = agent.id
    MLS.post("/contacts/#{token}/claim", {:agent_id => agent.id})
  end

  def decline(notes=nil)
    self.agent_comments = notes
    MLS.post("/contacts/#{token}/decline", {:agent_comments => notes})
  end

  def view
    MLS.post("/contacts/#{token}/view")
  end

  def viewed?
    status != "new"
  end

  def claimed?
    status == "claimed"
  end

  def declined?
    status == "declined"
  end

  class << self
    def get_all_for_account
      response = MLS.get('/account/contacts')
      MLS::Contact::Parser.parse_collection(response.body)
    end

    def find_by_token(token)
      response = MLS.get("/contacts/#{token}")
      MLS::Contact::Parser.parse(response.body)
    end

    def create(listing_id, account, contact={})
      params = {:account => account, :contact => contact}
      response = MLS.post("/listings/#{listing_id}/contacts", params)
      return MLS::Contact::Parser.parse(response.body)
    end
  end

end

class MLS::Contact::Parser < MLS::Parser
  
  def listing=(listing)
    @object.listing = MLS::Listing::Parser.build(listing)
  end
  
  def client=(account)
    @object.client = MLS::Account::Parser.build(account)
  end

end
