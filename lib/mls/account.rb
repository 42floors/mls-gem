class Account < MLS::Model

  belongs_to :avatar, :class_name => 'Photo'
  
  belongs_to :brokerage

  has_many :agencies, :inverse_of => :agent, :foreign_key => :agent_id
  
  # def self.authenticate(email, pass)
  #   account = where(arel_table[:email].eq(email.try(:downcase)).and(arel_table[:password_digest].not_eq(nil))).first
  #   account && BCrypt::Password.new(account.password_digest) == pass ? account : nil
  # end


end
