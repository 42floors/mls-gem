class MLS::Address < MLS::Resource
  
  def self.query(q)
    get :query, :query => q
  end

  private

  def self.instantiate_collection(collection, prefix_options = {})
    collection['addresses'].collect! { |record| instantiate_record(record, prefix_options) }
  end  
end
