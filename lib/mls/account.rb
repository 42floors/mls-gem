class Account < MLS::Model

  include MLS::Avatar

  has_one :lead, foreign_key: :account_id

  belongs_to :organization

  has_many :agencies, :inverse_of => :agent, :foreign_key => :agent_id

end
