class MLS::TourRequest < MLS::Resource
  property :message, String

  property :id,                           Fixnum
  property :account_id,                   Fixnum
  property :listing_id,                   Fixnum
  property :message,                      String
  property :company,                      String
  property :population,                   String
  property :growing,                      Boolean
  property :updated_by_id,                Fixnum
  property :status,                       String
  property :reasons_to_decline,           String,    :serialize => :if_present

  property :token,                        String,    :serialize => :false

  property :created_at,                   DateTime,  :serialize => :false
  property :updated_at,                   DateTime,  :serialize => :false

  attr_accessor :account, :listing, :additional_features

  def claim(agent)
    MLS.post("/tour_requests/#{token}/claim", {:agent_id => agent.id}) do |response, code|
      return code == 200
    end
  end

  def decline(agent, reasons=nil)
    MLS.post("/tour_requests/#{token}/decline", 
      {:agent_id => agent.id, :reasons_to_decline => reasons}) do |response, code|
      return code == 200
    end
  end

  def view(agent)
    MLS.post("/tour_requests/#{token}/view", {:agent_id => agent.id}) do |response, code|
      return code == 200
    end
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

  def to_hash
    hash = super
    hash[:additional_features_attributes] = additional_features.to_hash if additional_features
    hash
  end

  class << self
    def get_all_for_account
      response = MLS.get('/account/tour_requests')
      MLS::TourRequest::Parser.parse_collection(response.body)
    end

    def find_by_token(token)
      response = MLS.get("/tour_requests/#{token}")
      MLS::TourRequest::Parser.parse(response.body)
    end

    def create(listing_id, account, tour={})
      params = {:account => account, :tour => tour}
      response = MLS.post("/listings/#{listing_id}/tour_requests", params)
      return MLS::TourRequest::Parser.parse(response.body)
    end
  end
end

class MLS::TourRequest::Parser < MLS::Parser
  
  def listing=(listing)
    @object.listing = MLS::Listing::Parser.build(listing)
  end
  
  def account=(account)
    @object.account = MLS::Account::Parser.build(account)
  end
end
