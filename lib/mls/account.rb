class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  has_one :lead, foreign_key: :account_id

  belongs_to :organization

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
    if email_addresses.loaded?
      email_addresses.to_a.find{|p| p.primary }.try(:address)
    else
      email_addresses.primary.try(:address)
    end
  end
  
  def phone
    if phones.loaded?
      phones.to_a.find{|p| p.primary }.try(:number)
    else
      phones.primary.try(:number)
    end
  end
  
  def company_name
    return organization.name if organization
    return company
  end

end
