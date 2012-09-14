class MLS::TourRequest < MLS::Resource
  property :message, String

  property :id,                           Fixnum
  property :account_id,                   Fixnum
  property :listing_id,                   Fixnum
  property :message,                      String
  property :company,                      String
  property :population,                   String
  property :funding,                      String
  property :move_in_date,                 String
  property :created_at,                   DateTime,  :serialize => :false
  property :updated_at,                   DateTime,  :serialize => :false

  attr_accessor :account, :listing

  class << self
    def get_all_for_account
      response = MLS.get('/account/tour_requests')
      MLS::TourRequest::Parser.parse_collection(response.body)
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