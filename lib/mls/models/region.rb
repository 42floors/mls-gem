class MLS::Region < MLS::Resource

  property :id,             Fixnum, :serialize => :if_present
  property :name,           String, :serialize => :if_present
  property :common_name,    String, :serialize => :if_present
  property :description,    String, :serialize => :if_present
  property :code,           String, :serialize => :if_present
  property :type,           String, :serialize => :if_present
  property :source,         String, :serialize => :if_present
  property :minimum_zoom,   Fixnum, :serialize => :if_present
  property :maximum_zoom,   Fixnum, :serialize => :if_present
  property :slug,           String, :serialize => false
  property :geometry,       Hash,   :serialize => false
  property :envelope,       Hash,   :serialize => false
  
  # Counter caches
  property :listings_count, Fixnum, :serialize => :false

  class << self
    
    def find(id)
      response = MLS.get("/regions/#{id}")
      MLS::Region::Parser.parse(response.body)
    end
    
  end

end


class MLS::Region::Parser < MLS::Parser

end
