class Inquiry < MLS::Model

  has_many :emails
  belongs_to :lead
  belongs_to :subject, polymorphic: true
  belongs_to :account

  accepts_nested_attributes_for :account

  def property
    subject.is_a? MLS::Model::Listing ? subject.property : subject
  end
  
  def account_attributes=(account_attrs)
    account_attrs = account_attrs&.with_indifferent_access
    self.account = if account_attrs.nil?
      nil
    elsif account_attrs["id"]
      accnt = Account.find(account_attrs.delete("id"))
      accnt.assign_attributes(account_attrs)
      accnt
    else
      if account_attrs["email_addresses_attributes"]
        email_address = EmailAddress.filter(address: account_attrs["email_addresses_attributes"].map{|ea| ea["address"].downcase}, account_id: true).first
        accnt = email_address.account
        accnt.assign_attributes(account_attrs)
      end
      
      if !accnt && account_attrs["phones_attributes"]
        phone = Phone.filter(number: account_attrs["phones_attributes"].map{|p| PhoneValidator.normalize(p["number"])}, account_id: true).first
        accnt = phone.account
        accnt.assign_attributes(account_attrs)
      end
      
      if !accnt
        accnt = Account.new(account_attrs)
      end

      accnt
    end
  end
  
  def self.by_day(filter)
    req = Net::HTTP::Get.new("/inquiries/by_day")
    req.body = {
      where: filter
    }.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end

end
