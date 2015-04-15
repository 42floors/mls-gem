class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_one :lead, foreign_key: :account_id

  belongs_to :organization

  has_many :tasks
  has_many :sources
  has_many :agencies, :inverse_of => :agent, :foreign_key => :agent_id

  has_many :email_addresses, :dependent => :destroy do
    def primary
      where(:primary => true).first
    end
  end

  has_many :phones, dependent: :destroy do

    def primary
      where(primary: true).first
    end

  end

end
