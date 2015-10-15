class GreenSheet < MLS::Model

  has_one :account, :foreign_key => :green_sheet_uuid
  
end
