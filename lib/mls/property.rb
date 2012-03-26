class MLS::Property < MLS::Resource

  def addresses
    @addresses ||= MLS::Address.all :params => {:property_id => id}
  end

  private

  def self.instantiate_collection(collection, prefix_options = {})
    puts collection
    collection['properties'].collect! { |record| instantiate_record(record, prefix_options) }
  end

end
