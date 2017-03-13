class Account < MLS::Model

  include MLS::Slugger
  include MLS::Avatar

  belongs_to :organization
  belongs_to :membership

  has_many :tasks
  has_many :sources
  has_many :ownerships, :inverse_of => :account, :dependent => :delete_all
  has_many :assets, through: :ownerships
  has_many :coworking_spaces, through: :ownerships, source: :asset, source_type: 'CoworkingSpace'
  has_many :listings, through: :ownerships, source: :asset, source_type: 'Listing', inverse_of: :accounts
  has_many :email_digests
  has_many :subscriptions, as: :subject
  has_many :leads
  
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
    
  attr_accessor :password, :password_required
  accepts_nested_attributes_for :phones, :email_addresses
  
  validates :password, confirmation: true, if: Proc.new {|a| (!a.persisted? && a.password_required?) || !a.password.nil? }
  validates :password, length: { minimum: 6 }, if: :password
  validates :password_confirmation, presence: true, if: :password
  
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
    self.membership&.subscriptions&.filter(started_at: true, status: {not: "closed"}, type: "tim_alerts", subject_id: self.id, subject_type: "Account")&.count.try(:>, 0)
  end

  def unlimited?
    self.membership&.subscriptions&.filter(started_at: true, status: {not: "closed"}, type: "unlimited", subject_id: self.id, subject_type: "Account")&.count.try(:>, 0)
  end
  
  def paying?
    self.membership&.subscriptions&.filter(started_at: true, status: {not: "closed"})&.count.try(:>, 0)
  end
  
  def password_required?
    @password_required != false
  end
  
  def password=(pass)
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
  
  def self.by_lead_size(filter)
    req = Net::HTTP::Get.new("/accounts/by_lead_size")
    req.body = {
      where: filter
    }.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
  
  def self.by_inquiry_size(filter)
    req = Net::HTTP::Get.new("/accounts/by_inquiry_size")
    req.body = {
      where: filter
    }.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
    

end
