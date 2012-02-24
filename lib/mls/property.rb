class MLS::Property < MLS::Resource

  def addresses
    @addresses ||= MLS::Address.all :params => {:property_id => id}
  end

end
