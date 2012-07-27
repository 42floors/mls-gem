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
  property :system_phone,            String
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
  property :population,              String
  property :growing,                 Boolean
  property :move_in,                 String
  property :extra_info,              String

  exclude_from_comparison :password, :password_confirmation

  attr_reader :favorite_ids

  def update
    MLS.put('/account', to_hash) do |code, response|
      case code
      when 200
        MLS::Account::Parser.update(self, response.body)
        true
      when 400
        MLS::Account::Parser.update(self, response.body)
        false
      else
        MLS.handle_response(response)
        raise "shouldn't get here...."
      end
    end
  end
  
  def create
    MLS.post('/account', to_hash) do |code, response|
      case code
      when 201
        MLS::Account::Parser.update(self, response.body)
        @persisted = true
      when 400
        MLS::Account::Parser.update(self, response.body)
        false
      else
        MLS.handle_response(response)
        raise "shouldn't get here...."
      end
    end
  end

  def agent?
    role != 'user' && role != ''
  end

  def favorites
    response = MLS.get('/account/favorites')
    MLS::Listing::Parser.parse_collection(response.body, {:collection_root_element => :favorites})
  end

  def favorited?(listing)
    if favorite_ids
      favorite_ids.include?(listing.id) 
    else
      favorites.include?(listing)
    end
  end
  
  def favorite(listing_id)
    params_hash = {:id => listing_id}
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
      MLS.post('/account/password/reset', params_hash) do |code, response|
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

  def favorite_ids=(ids)
    @object.instance_variable_set('@favorite_ids', ids)
  end

end
