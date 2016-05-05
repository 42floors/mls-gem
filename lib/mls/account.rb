class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  belongs_to :organization

  has_many :tasks
  has_many :sources
  has_many :ownerships, :inverse_of => :account, :dependent => :delete_all
  has_many :assets, through: :ownerships
  has_many :coworking_spaces, through: :ownerships, source: :asset, source_type: 'CoworkingSpace'
  has_many :listings, through: :ownerships, source: :asset, source_type: 'Listing', inverse_of: :agents
  
  has_many :accounts_regions do 
    def primary
      where(primary: true).order(asset_count: :desc)
    end
  end
  
  has_many :regions, through: :accounts_regions do 
    def primary
      where(accounts_regions: {primary: true}).order(:"accounts_regions.asset_count" => :desc)
    end
  end
  
  has_many :credit_cards
  
  has_many :memberships
  has_one :membership, -> { where(ended_at: nil) }

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
  
  attr_accessor :password, :password_required
  accepts_nested_attributes_for :phones, :email_addresses, :regions, :accounts_regions
  
  validates :password, :confirmation => true, :if => Proc.new {|a| (!a.persisted? && a.password_required?) || !a.password.nil? }
  validates :password_confirmation, :presence => true, :if => :password
  
  def properties
    Property.filter(listings: {ownerships: {account_id: self.id}})
  end
  
  def password_required?
    @password_required != false
  end
  
  def password=(pass)
    return if pass.blank?
    @password = pass
    self.password_digest = BCrypt::Password.create(pass)
  end
  
  def email_address
    email_addresses.to_a.find{|p| p.primary }.try(:address)
  end
  
  def regions_attributes=(regions_attrs)
    # regions.clear was trying to destroy all regions going to "/accounts_regions/" method = Destroy
    AccountsRegion.where(:agent_id => self.id).destroy_all
    return if regions_attrs.nil?
    regions_attrs.each do |attrs|
      region = Region.find(attrs["id"])
      regions.push(region)
    end
  end
  
  def phone
    (phones.to_a.find{|p| p.primary } || phones.first).try(:number)
  end
  
  def role?(*compare_roles)
    (roles & compare_roles).any?
  end
  alias_method :roles?, :role?
  
  def company_name
    return organization.name if organization
    return company
  end
  
  def self.send_reset_password_email(url, email_address)
    req = Net::HTTP::Post.new("/accounts/password")
    req.body = { email_address: email_address, url: url }.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
  end
  
  def self.update_password(token, password, password_confirmation)
    req = Net::HTTP::Put.new("/accounts/password")
    req.body = {
      token: token,
      password: password,
      password_confirmation: password_confirmation
    }.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
  end
  
  def self.confirm(token)
    req = Net::HTTP::Post.new("/accounts/confirm")
    req.body = { token: token }.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
    return true
  rescue Sunstone::Exception::NotFound
    return false
  end
  
  def send_confirmation_email(url)
    req = Net::HTTP::Post.new("/accounts/#{self.id}/confirm")
    req.body = {url: url}.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
  end

end
