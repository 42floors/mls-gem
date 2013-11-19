class MLS::Region < MLS::Resource

  property :id,             Fixnum
  property :name,           String
  property :proper_name,    String
  property :common_name,    String
  property :code,           String
  property :type,           String
  property :source,         String
  property :minimum_zoom,   Fixnum
  property :maximum_zoom,   Fixnum
  property :slug,           String
  property :geometry,       Hash
  property :envelope,       Hash
  property :children,       Hash

  # Counter caches
  property :listings_count, Fixnum, :serialize => :false

  class << self

    def find(id)
      response = MLS.get("/regions/#{id}")
      MLS::Region::Parser.parse(response.body)
    end

  end

  def name
    common_name || proper_name
  end

  def bounds
    return nil unless envelope
    n, e, s, w = nil, nil, nil, nil
    envelope[:coordinates][0].each do |c|
      lon, lat = *c
      n = lat if !n || lat > n
      e = lon if !e || lon > e
      s = lat if !s || lat < s
      w = lon if !w || lon < w
    end
    [n, e, s, w]
  end

end


class MLS::Region::Parser < MLS::Parser

end
