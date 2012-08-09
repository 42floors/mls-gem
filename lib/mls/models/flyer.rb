require 'restclient'

class MLS::Flyer < MLS::Resource

  property :id, Fixnum
  property :created_at, DateTime
  property :updated_at, DateTime
  property :file_content_type, String
  property :file_name, String
  property :file_size, Fixnum
  property :url, String

  def self.create(file)
    file.rewind
    url = MLS.url.dup
    url.user = nil
    url.path = "/api/flyers"
    response = RestClient.post(url.to_s, {:file => file}, MLS.headers)
    file.close unless file.closed?

    MLS::Flyer::Parser.parse(response.body)
  end
  
end

class MLS::Flyer::Parser < MLS::Parser

end
