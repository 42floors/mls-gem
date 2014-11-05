class Comment < MLS::Model

  belongs_to :account
  belongs_to :subject, :polymorphic => true

end
