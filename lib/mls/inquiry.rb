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
    if account_attrs[:email_addresses_attributes]
      account = Account.filter(
        :email_addresses => {
          :address => account_attrs[:email_addresses_attributes][0][:address].try(:downcase)
        }
      ).first
      if account
        account_attrs.delete(:email_addresses_attributes)
        account_attrs[:phones_attributes].each_with_index do |phone_attrs, index|
          number = PhoneValidator.normalize(phone_attrs[:number])
          account_attrs[:phones_attributes].delete_at(index) if Phone.where(number: number).count > 0
        end
        self.account_id = account.id
        account_attrs[:id] = account.id
        account.update_attributes(account_attrs)
        super
      else
        super
      end
    else
      super
    end
  end

end
