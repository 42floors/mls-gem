class MLS::Video < MLS::Resource
  property :id, Fixnum
  property :vts_key, String
  property :video_type, String
  property :subject_type, String
  property :created_at, DateTime, :serialize => :if_present
  property :updated_at, DateTime, :serialize => :if_present
end

class MLS::Video::Parser < MLS::Parser

end
