class MLS::Video < MLS::Resource
  property :id, Fixnum
  property :vts_key, String
  property :video_type, String
  property :subject_type, String, :serialize => false
  property :created_at, DateTime, :serialize => :if_present
  property :updated_at, DateTime, :serialize => :if_present

  property :photo_id, Fixnum, :serialize => :if_present

  attr_accessor :photo
end

class MLS::Video::Parser < MLS::Parser
  def photo=(photo)
    @object.photo = MLS::Photo::Parser.build(photo)
  end
end
