class MLS::Area < MLS::Resource

  property :id,             Fixnum, :serialize => :if_present
  property :name,           String, :serialize => :if_present
  property :level,          Fixnum, :serialize => :if_present
  property :type,           String, :serialize => :if_present
  property :source,         String, :serialize => :if_present
  property :geometry,       Hash,   :serialize => false
  
  # Counter caches
  property :listings_count, Fixnum, :serialize => :false

  class << self
    
    def find(id)
      response = MLS.get("/areas/#{id}")
      MLS::Area::Parser.parse(response.body)
    end
    
  end

end


class MLS::Area::Parser < MLS::Parser

end
