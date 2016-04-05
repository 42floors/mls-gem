class Ownership < MLS::Model

  belongs_to :account
  belongs_to :asset, polymorphic: true

  accepts_nested_attributes_for :account

end
