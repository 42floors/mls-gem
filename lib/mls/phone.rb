class Phone < MLS::Model
  self.inheritance_column = false

  TYPES = ['mobile', 'work', 'home', 'main', 'home fax' 'work fax', 'other fax', 'pager', 'other', 'office']

  belongs_to :account
  
  def number=(value)
    write_attribute(:number, PhoneValidator.normalize(value))
    write_attribute(:carrier_name, nil)
    write_attribute(:carrier_type, nil)
  end
  
end
