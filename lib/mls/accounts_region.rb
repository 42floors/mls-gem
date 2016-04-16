class AccountsRegion < MLS::Model
  
  belongs_to :agent, :class_name => 'Account'
  belongs_to :region
  
end
