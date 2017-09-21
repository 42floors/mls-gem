class Suggestion < MLS::Model
  
  STATUS_OPTIONS = %w(proposed confirmed rejected)
  
  belongs_to :search
  belongs_to :listing
  belongs_to :suggested_by, class_name: "Account"

end
