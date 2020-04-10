class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  belongs_to :organization
  belongs_to :cobroke_manager, class_name: "Account"
  
  has_and_belongs_to_many :subscriptions
  has_many :tasks
  has_many :ownerships, :inverse_of => :account, :dependent => :delete_all
  has_many :assets, through: :ownerships
  has_many :coworking_spaces, through: :ownerships, source: :asset, source_type: 'CoworkingSpace'
  has_many :listings, through: :ownerships, source: :asset, source_type: 'Listing', inverse_of: :accounts
  has_many :sites, through: :ownerships, source: :asset, source_type: 'Site', inverse_of: :accounts
  has_many :email_digests
  has_many :services, as: :subject
  has_many :tim_alerts
  has_many :references, as: :subject
  
  has_many :searches
  has_many :suggestions, foreign_key: "suggested_by_id"
  has_many :broadcasts, foreign_key: :sender_id
  
  has_many :credit_cards

  has_many :email_addresses do
    def primary
      # For cases where the number is not primary we order
      if loaded?
        select{|x| x.primary}.first
      else
        order(:primary => :desc).first
      end
    end
  end
  
  def deals
    Search.filter([{manager_id: self.id}, "OR", {broker_id: self.id}])
  end

  has_many :phones do

    def primary
      # For cases where the number is not primary we order
      if loaded?
        select{|x| x.primary}.first
      else
        order(:primary => :desc).first
      end
    end

  end
  
  has_and_belongs_to_many :advertised_regions, join_table: 'accounts_regions_advertised', class_name: 'Region'
  has_and_belongs_to_many :inquiries
  has_and_belongs_to_many :teams
    
  attr_accessor :password_required
  accepts_nested_attributes_for :phones, :email_addresses
  
  validates :password, length: { minimum: 6 }, if: :password

  rpc :unsubscribe_from_broadcasts
  
  def regions
    Region.filter(id: {in: self.advertised_region_ids})
  end
  
  def city_regions
    advertised_regions.filter(type: Region::CITY_TYPES).order(listings_count: :desc)
  end
  
  def properties
    Property.where(listings: {ownerships: {account_id: self.id}})
  end
  
  def tim_alerts?
    subscriptions.map{|x| x.services.filter(status: "active", type: "tim_alerts").count}.sum > 0
  end

  def unlimited?
    subscriptions.map{|x| x.services.filter(status: "active", type: "unlimited").count}.sum > 0
  end
  
  def referral?
    subscriptions.map{|x| x.services.filter(status: "active", type: "referral").count}.sum > 0
  end
  
  def paying?
    subscriptions.map{|x| x.services.filter(status: "active").count}.sum > 0
  end
  
  def password_required?
    @password_required != false
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
  
  def merge_in(account_id)
    req = Net::HTTP::Put.new("/accounts/#{self.id}/merge")
    req.body = { account_id: account_id }.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
    return true
  rescue Sunstone::Exception::NotFound
    return false
  end
  
  def self.send_reset_password_email(url, email_address)
    req = Net::HTTP::Post.new("/accounts/password")
    req.body = { email_address: email_address, url: url }.to_json
    Account.connection.instance_variable_get(:@connection).send_request(req)
  end
  
  def self.update_password(token, password)
    req = Net::HTTP::Put.new("/accounts/password")
    req.body = {
      token: token,
      password: password
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
  
  def set_confirmation_token
    req = Net::HTTP::Get.new("/accounts/#{self.id}/confirm")
    response = Account.connection.instance_variable_get(:@connection).send_request(req)
    self.confirmation_token = response.body
  end
    

end
