class Session < MLS::Model

  belongs_to :account

  def self.authenticate(email, password)
    Session.create(:email => email, :password => password)
  end

  def self.authenticate_by_token(token)
    Session.create(:token => token)
  end

end