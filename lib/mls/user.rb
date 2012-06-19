class MLS::User < MLS::Resource

  def self.query(q)
    instantiate_collection(get(:query, :query => q))
  end

end
