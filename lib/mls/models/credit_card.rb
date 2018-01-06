class CreditCard < MLS::Model

  belongs_to :account
  
  def name
    string = "&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;&bull; &bull;" if self.brand == "American Express"
    string ||= "&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; "
    string += self.last4
  end

end