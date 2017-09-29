class Search < MLS::Model

  STATUS_OPTIONS = %w(active closed nurturing)
  STAGE_OPTIONS = %w(initiated delivered connected toured loi signed)
  
  belongs_to :account
  belongs_to :broker, class_name: "Account"
  belongs_to :manager, class_name: "Account"
  
  has_many :suggestions
  has_many :email_digests
  
  accepts_nested_attributes_for :account
  
  def filter
    JSON.parse (read_attribute(:filter) || {}).to_json, object_class: OpenStruct
  end
  
  def regions
    Region.where(id: self.region_ids)
  end

end
