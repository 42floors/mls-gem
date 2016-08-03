class Subscription < MLS::Model

  belongs_to :membership
  belongs_to :subject, polymorphic: true

end