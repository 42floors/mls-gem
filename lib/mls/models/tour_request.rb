class MLS::TourRequest < MLS::Resource
  property :message,                         String

  attr_accessor :listing

  class << self
    def get_all_for_account
      MLS.get('/account/tour_requests') do |code, response|
        case code
        when 400
          @errors = MLS.parse(response.body)[:errors]
          return false
        else
          MLS.handle_response(response)
          return MLS::TourRequest::Parser.parse_collection(response.body)
        end
      end
    end

    def create(listing_id, message, account_params={})
      params = account_params
      params[:id] = listing_id
      params[:message] = message
      MLS.post('/account/tour_requests', params) do |code, response|
        case code
        when 400
          return MLS::TourRequest::Parser.parse(response.body)
        else
          MLS.handle_response(response)
          puts response.body
          return MLS::TourRequest::Parser.parse(response.body)
        end
      end
    end
  end
end

class MLS::TourRequest::Parser < MLS::Parser
  
  def listing=(listing)
    @object.listing = MLS::Listing::Parser.build(listing)
  end
end
