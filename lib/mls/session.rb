class Session < MLS::Model

  belongs_to :account

  # Authenticate with email and password.
  # Returns either the newly created session or nil
  def self.authenticate(email, password=nil)
    if email.is_a? Hash
      password = email[:password]
      email = email[:email]
    end
    
    Session.create(:email => email, :password => password)
  rescue Sunstone::Exception::Unauthorized
    nil
  end

  def self.authenticate_by_token(token)
    Session.create(:token => token)
  end

end