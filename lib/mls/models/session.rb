class Session < MLS::Model

  belongs_to :account

  # Authenticate with email_address and password.
  # Returns either the newly created session or nil
  def self.authenticate(email_address, password=nil)
    if email_address.is_a? Hash
      password = email_address[:password]
      email_address = email_address[:email_address]
    end
    
    Session.create!(:email_address => email_address, :password => password)
  rescue Sunstone::Exception::Unauthorized, ActiveRecord::RecordInvalid
    nil
  end

  def self.authenticate_by_token(token)
    Session.create(:token => token)
  end

end