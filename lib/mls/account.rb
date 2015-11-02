class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_one :lead, foreign_key: :account_id

  belongs_to :organization
  belongs_to :green_sheet, :foreign_key => :green_sheet_uuid

  has_many :tasks
  has_many :sources
  has_many :agencies, :inverse_of => :agent, :foreign_key => :agent_id
  
  has_and_belongs_to_many :regions, :foreign_key => :agent_id

  has_many :email_addresses do
    def primary
      # For cases where the number is not primary we order
      order(:primary => :desc).first
    end
  end

  has_many :phones do

    def primary
      # For cases where the number is not primary we order
      order(:primary => :desc).first
    end

  end
  
  def email_address
    email_addresses.to_a.find{|p| p.primary }.try(:address)
  end
  
  def phone
    (phones.to_a.find{|p| p.primary } || phones.first).try(:number)
  end
  
  def company_name
    return organization.name if organization
    return company
  end

end
