class Account < MLS::Model

  include MLS::Avatar
  
  belongs_to :organization

  has_many :agencies, :inverse_of => :agent, :foreign_key => :agent_id
  
  # def self.authenticate(email, pass)
  #   account = where(arel_table[:email].eq(email.try(:downcase)).and(arel_table[:password_digest].not_eq(nil))).first
  #   account && BCrypt::Password.new(account.password_digest) == pass ? account : nil
  # end


end
