class MLS::Account < MLS::Resource
  
  ROLES = %w(user broker property_manager landlord analyst assistant other)
  DEFAULTS = {:role => 'user'}

  property :id,                      Fixnum
  property :type,                    String,   :default => 'User'
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
  property :system_phone,            String
  
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

  attr_accessor :password_required

  attr_writer :favorites

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
  
  # Save the Account to the MLS. @errors will be set on the account if there
  # are any errors. @persisted will also be set to +true+ if the Account was
  # succesfully created
  def create
    MLS.post('/account', to_hash, 400) do |response, code|
      raise MLS::Exception::UnexpectedResponse if ![201, 400].include?(code)
      MLS::Account::Parser.update(self, response.body)
      @persisted = true
    end
  end

  def agent?
    role != 'user' && role != ''
  end

  def favorites
    return @favorites if @favorites
    response = MLS.get('/account/favorites')
    @favorites = MLS::Listing::Parser.parse_collection(response.body, {:collection_root_element => :favorites})
  end
  
  def favorited?(listing)
    favorites.include?(listing)
  end
  
  def favorite(listing) # TODO: fixme and test me
    params_hash = {:id => listing.is_a?(MLS::Listing) ? listing.id : listing }
    MLS.post('/account/favorites', params_hash) do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        @favorites = nil
        return true
      end
    end
  end

  def unfavorite(listing_id)
    listing_id = listing_id.is_a?(MLS::Listing) ? listing_id.id : listing_id
    MLS.delete("/account/favorites/#{listing_id}") do |code, response|
      case code
      when 400
        @errors = MLS.parse(response.body)[:errors]
        return false
      else
        MLS.handle_response(response)
        @favorites = nil
        return true
      end
    end
  end

  def to_hash
    hash = super
    hash[:password_required] = password_required unless password_required.nil?
    hash
  end
    
  class << self

    def current
      response = MLS.get('/account')
      MLS::Account::Parser.parse(response.body)
    end
    
    # Authenticate and Account via <tt>email</tt> and <tt>password</tt>. Returns
    # the <tt>Account</tt> object if successfully authenticated. Returns <tt>nil</tt>
    # if the account could not be found, password was incorrect, or the account
    # was revoked
    #
    # ==== Examples
    #  #!ruby
    #  Account.authenticate(:email => 'jon@does.net', :password => 'opensesame') # => #<Account>
    #    
    #  Account.authenticate('jon@does.net', 'opensesame') # => #<Account>
    #
    #  Account.authenticate('jon@does.net', 'wrong') # => nil
    def authenticate(attrs_or_email, password=nil)
      email = attrs_or_email.is_a?(Hash) ? attrs_or_email[:email] : attrs_or_email
      password = attrs_or_email.is_a?(Hash) ? attrs_or_email[:password] : password
      
      response = MLS.get('/account', {:email => email, :password => password})
      MLS::Account::Parser.parse(response.body)
    rescue MLS::Exception::Unauthorized => response
      nil
    end

    def reset_password!(email)
      MLS.put('/account/reset_password', {:email => email}) do |code, response|
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
      response = MLS.put('/account/update_password', params_hash)
      MLS::Account::Parser.parse(response)
    rescue MLS::Exception::BadRequest => response
      @errors = MLS.parse(response.message)
      return false
    end

    def search(terms)
      results = nil
      MLS.get('/account/search', :query => terms) do |code, response|
        case code
        when 200
          results = MLS::Account::Parser.parse_collection(response.body)
        else
          MLS.handle_response(response)
        end
      end
      results
    end

  end
  
end

class MLS::Account::Parser < MLS::Parser

  def favorites=(favorites)
    @object.favorites = favorites.map {|a| MLS::Listing::Parser.build(a) }
  end

end
