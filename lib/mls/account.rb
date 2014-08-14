module MLS
  class Account < Sunstone::Model

    # Relationships =============================================================
    belongs_to :avatar, :class_name => 'MLS::Photo'
    # belongs_to :brokerage
    # belongs_to :contact, :class_name => 'Account'
    #
    # favorites
    # has_many :listings
    # has_many :properties
    # has_many :comments
    # has_and_belongs_to_many :regions

    # Accessors =================================================================
    attr_accessor :password_required

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
    # def self.authenticate(email, password=nil)
    #   MLS.post('/login', {:email => email, :password => password}) do |response|
    #     # Parse and return account
    #   end
    # rescue MLS::Exception::Unauthorized
    #   nil
    # end

    # def self.reset_password!(email, url)
    #   MLS.post('/account/password', {:email => email, :url => url}, 400, 404) do |response, code|
    #     code == 204
    #   end
    # end
    #
    # def update_password!(token, password, password_confirmation)
    #   MLS.put('/account/password', {:token => token, :password => password, :password_confirmation => password_confirmation}, 400) do |response, code|
    #     MLS::Account::Parser.parse(response.body)
    #   end
    # end

  end
end