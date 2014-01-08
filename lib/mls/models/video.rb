class MLS::Video < MLS::Resource
  attribute :id, Fixnum
  attribute :vts_key, String
  attribute :video_type, String
  attribute :subject_type, String, :serialize => false
  attribute :created_at, DateTime, :serialize => :if_present
  attribute :updated_at, DateTime, :serialize => :if_present

  attribute :photo_id, Fixnum, :serialize => :if_present

  attr_accessor :photo
end

class MLS::Video::Parser < MLS::Parser
  def photo=(photo)
    @object.photo = MLS::Photo::Parser.build(photo)
  end
end
