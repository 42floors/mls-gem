class Suggestion < MLS::Model

  belongs_to :search
  belongs_to :listing
  belongs_to :suggested_by, class_name: "Account"

end
