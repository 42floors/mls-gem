class Datum < MLS::Model

  belongs_to :subject, :polymorphic => true

end
