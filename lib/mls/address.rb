class MLS::Address < MLS::Resource
  
  def self.query(q)
    get :query, :query => q
  end
  
end
