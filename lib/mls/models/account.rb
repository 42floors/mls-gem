class MLS::Account < MLS::Resource
  
  ROLES = %w(user broker property_manager landlord analyst assistant other)
  DEFAULTS = {:role => 'user'}

  property :id,                      Fixnum
  property :role,                    String,   :default => 'user'
  property :name,                    String
  property :title,                   String
  property :email,                   String
  property :password,                String,   :serialize => :if_present
  property :password_confirmation,   String,   :serialize => :if_present
  property :perishable_token,        String
  property :perishable_token_set_at, String
  
  property :phone,                   String
  property :company,                 String
  property :license,                 String
  property :linkedin,                String
  property :twitter,                 String
  property :facebook,                String
  property :web,                     String
  property :mls_number,              String
  
  property :city,                    String
  property :state,                   String
  property :country,                 String
  
  property :auth_key,                String

  property :funding,                 String
  property :message,                 String
  property :population,              String
  property :growing,                 Boolean
  property :move_in,                 String
  property :extra_info,              String
  
  def update!
    MLS.put('/account', to_hash) do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        MLS::Account::Parser.update(self, response.body)
      end
    end
  end
  
  def create!
    Rails.logger.warn(to_hash)
    MLS.post('/account', to_hash) do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        MLS::Account::Parser.update(self, response.body)
      end
    end
  end

  def agent?
    role != 'user' && role != ''
  end

  def favorites
    response = MLS.get('/account/favorites')
    MLS::Listing::Parser.parse_collection(response.body)
  end
  
  def favorite(listing_id)
    params_hash = {:id => listing_id}
    Rails.logger.warn(params_hash)
    MLS.post('/account/favorites', params_hash) do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        return true
      end
    end
  end

  def unfavorite(listing_id)
    MLS.delete("/account/favorites/#{listing_id}") do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        return true
      end
    end
  end

  class << self
    
    def current
      response = MLS.get('/account')
      MLS::Account::Parser.parse(response.body)
    end
    
    def authenticate(attrs_or_email, password=nil)
      email = attrs_or_email.is_a?(Hash) ? attrs_or_email[:email] : attrs_or_email
      password = attrs_or_email.is_a?(Hash) ? attrs_or_email[:password] : password
      
      response = MLS.get('/account', {:email => email, :password => password})
      MLS::Account::Parser.parse(response.body)
    rescue MLS::Unauthorized => response
      nil
    end

    def reset_password!(email)
      params_hash = {:email => email}
      Rails.logger.warn(params_hash)
      MLS.post('/accounts/password/reset', params_hash) do |code, response|
        case code
        when 400
          @errors = MLS.parse(response.body)[:errors]
          return false
        else
          MLS.handle_response(response)
          return true
        end
      end
    end

    def update_password!(params_hash)
      Rails.logger.warn(params_hash)
      response = MLS.put('/accounts/password', params_hash)
      MLS::Account::Parser.parse(response)
    rescue MLS::BadRequest => response
      @errors = MLS.parse(response.message)
      return false
    end

  end
  
end

class MLS::Account::Parser < MLS::Parser

end
