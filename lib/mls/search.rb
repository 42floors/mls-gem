class Search < MLS::Model

  belongs_to :account
  belongs_to :broker, class_name: "Account"
  belongs_to :manager, class_name: "Account"
  
  has_many :suggestions
  
  def filter
    JSON.parse (read_attribute(:filter) || {}).to_json, object_class: OpenStruct
  end

end
