class Search < MLS::Model

  STATUS_OPTIONS = %w(active hold cold closed)
  STAGE_OPTIONS = %w(initiated contacted delivered connected toured loi signed coworking)
  BUDGET_UNITS = %w(per_month per_year per_sqft_per_year)
  TERMS = %w(<1 1-2 3-5 5+ flexible)
  MOVE_INS = %w(<3 3-6 6-12 12+ flexible)
  
  belongs_to :account
  belongs_to :broker, class_name: "Account"
  belongs_to :manager, class_name: "Account"
  belongs_to :lead
  
  has_many :suggestions
  has_many :email_digests
  has_many :tasks, :as => :subject
  
  accepts_nested_attributes_for :account
  
  def filter
    JSON.parse (read_attribute(:filter) || {}).to_json, object_class: OpenStruct
  end
  
  def regions
    Region.where(id: self.region_ids)
  end
  
  def move_in_units(value=nil)
    value ||= self.move_in
    case value
    when "<1"
      "month"
    when "flexible"
      ""
    else
      "months"
    end
  end
  
  def term_units(value=nil)
    value ||= self.term
    case value
    when "<1"
      "year"
    when "flexible"
      ""
    else
      "years"
    end
  end
  
end
