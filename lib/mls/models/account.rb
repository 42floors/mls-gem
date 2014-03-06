class MLSGem::Account < MLSGem::Resource

  attribute :id,                      Fixnum,  :serialize => :if_present
  attribute :type,                    String,  :default => 'Account'
  attribute :name,                    String,  :serialize => :if_present
  attribute :title,                   String,  :serialize => :if_present
  attribute :email,                   String,  :serialize => :if_present
  attribute :password,                String,  :serialize => :if_present
  attribute :password_confirmation,   String,  :serialize => :if_present
  attribute :perishable_token,        String,  :serialize => false
  attribute :perishable_token_set_at, String,  :serialize => false
  attribute :ghost,                   Boolean, :serialize => false, :default => false

  attribute :phone,                   String,  :serialize => :if_present
  attribute :company,                 String,  :serialize => :if_present
  attribute :license,                 String,  :serialize => :if_present
  attribute :linkedin,                String,  :serialize => :if_present
  attribute :twitter,                 String,  :serialize => :if_present
  attribute :facebook,                String,  :serialize => :if_present
  attribute :web,                     String,  :serialize => :if_present
  attribute :direct_phone,            String,  :serialize => :if_present
  attribute :direct_email,            String,  :serialize => :if_present

  attribute :city,                    String,  :serialize => :if_present
  attribute :state,                   String,  :serialize => :if_present
  attribute :country,                 String,  :serialize => :if_present

  attribute :created_at,              DateTime,  :serialize => :false
  attribute :updated_at,              DateTime,  :serialize => :false

  attribute :email_token,             String,  :serialize => false
  attribute :auth_cookie,                String,  :serialize => false
  attribute :start_hours_of_operation, Fixnum,  :serialize => :if_present
  attribute :end_hours_of_operation,   Fixnum,  :serialize => :if_present
  attribute :days_of_operation,        String,  :serialize => :if_present
  attribute :timezone,                 String,  :serialize => :if_present
  attribute :lead_status,              String,  :serialize => :if_present
  attribute :buyer_id,                 Fixnum,  :serialize => :if_present

  exclude_from_comparison :password, :password_confirmation

  attr_accessor :password_required, :brokerage

  attr_writer :favorites

  def update
    raise "cannot update account without id" unless id
    MLSGem.put("/accounts/#{id}", { :account => to_hash}, 400) do |response, code|
      MLSGem::Account::Parser.update(self, response.body)
      code == 200
    end
  end

  # Save the Account to the MLSGem. @errors will be set on the account if there
  # are any errors. @persisted will also be set to +true+ if the Account was
  # succesfully created
  def create
    MLSGem.post('/accounts', {:account => to_hash}, 400) do |response, code|
      raise MLSGem::Exception::UnexpectedResponse if ![201, 400].include?(code)
      MLSGem::Account::Parser.update(self, response.body)
      @persisted = true
      code == 201
    end
  end

  def display_name
    name || email
  end

  def agent?
    type == 'Agent'
  end

  def favorites
    return @favorites if @favorites
    response = MLSGem.get('/account/favorites')
    @favorites = MLSGem::Listing::Parser.parse_collection(response.body, {:collection_root_element => :favorites})
  end

  def agent_profile
    @agent_profile ||= MLSGem.agent_profile id
  end

  def favorited?(listing)
    favorites.include?(listing)
  end

  def favorite(listing) # TODO: test me, i don't work on failures
    params_hash = {:id => listing.is_a?(MLSGem::Listing) ? listing.id : listing }
    MLSGem.post('/account/favorites', params_hash) do |response, code|
      @favorites = nil
      true
    end
  end

  def unfavorite(listing_id) # TODO: test me, i don't work on failures
    listing_id = listing_id.is_a?(MLSGem::Listing) ? listing_id.id : listing_id
    MLSGem.delete("/account/favorites/#{listing_id}") do |response, code|
      @favorites = nil
      true
    end
  end

  def to_hash
    hash = super
    hash[:password_required] = password_required unless password_required.nil?
    hash
  end

  class << self

    def current
      response = MLSGem.get('/account')
      MLSGem::Account::Parser.parse(response.body)
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

      response = MLSGem.post('/login', {:email => email, :password => password})
      MLSGem.auth_cookie = response['set-cookie']

      account = MLSGem::Account::Parser.parse(response.body)
      account.auth_cookie = MLSGem.auth_cookie
      account
    rescue MLSGem::Exception::Unauthorized => response
      nil
    end

    # URL is currently required to not have any query params in it
    def reset_password!(email, url)
      MLSGem.post('/account/password', {:email => email, :url => url}, 400, 404) do |response, code|
        code == 204
      end
    end

    def update_password!(token, password, password_confirmation)
      MLSGem.put('/account/password', {:token => token, :password => password, :password_confirmation => password_confirmation}, 400) do |response, code|
        MLSGem::Account::Parser.parse(response.body)
      end
    end

    def find(id, includes=[])
      response = MLSGem.get("/accounts/#{id}", :include =>  includes)
      MLSGem::Account::Parser.parse(response.body)
    end

    def where(terms)
      response = MLSGem.get('/accounts', :where => terms)
      MLSGem::Account::Parser.parse_collection(response.body)
    end

  end

end

class MLSGem::Account::Parser < MLSGem::Parser

  def favorites=(favorites)
    @object.favorites = favorites.map {|a| MLSGem::Listing::Parser.build(a) }
  end

  def brokerage=(brokerage)
    @object.brokerage = MLSGem::Brokerage::Parser.build(brokerage)
  end
end
