class MLSGem::Region < MLSGem::Resource

  attribute :id,             Fixnum
  attribute :name,           String
  attribute :proper_name,    String
  attribute :common_name,    String
  attribute :code,           String
  attribute :type,           String
  attribute :source,         String
  attribute :minimum_zoom,   Fixnum
  attribute :maximum_zoom,   Fixnum
  attribute :slug,           String
  attribute :geometry,       Hash
  attribute :envelope,       Hash
  attribute :children,       Hash

  # Counter caches
  attribute :properties_count, Fixnum

  class << self

    def find(id)
      response = MLSGem.get("/regions/#{id}")
      MLSGem::Region::Parser.parse(response.body)
    end

    def all(options={})
      response = MLSGem.get('/regions', options)
      MLSGem::Region::Parser.parse_collection(response.body)
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


class MLSGem::Region::Parser < MLSGem::Parser

end
