class Phone < MLS::Model
  self.inheritance_column = false

  TYPES = ['mobile', 'work', 'home', 'main', 'home fax' 'work fax', 'other fax', 'pager', 'other', 'office']

  belongs_to :account

end
