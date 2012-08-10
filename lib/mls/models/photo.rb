require 'restclient'

class MLS::Photo < MLS::Resource

  property :id, Fixnum
  property :digest, String
  property :created_at, DateTime
  property :updated_at, DateTime
  property :file_content_type, String
  property :file_name, String
  property :file_size, Fixnum
  property :url_template, String

  def url(style='large', protocol='http')
    "#{protocol}://#{MLS.asset_host}/photos/#{style}/#{@digest}.jpg"
  end

  def self.create(image_file)
    image_file.rewind
    url = MLS.url.dup
    url.user = nil
    url.path = "/api/photos"
    response = RestClient.post(url.to_s, {:file => image_file}, MLS.headers)
    image_file.close unless image_file.closed?

    MLS::Photo::Parser.parse(response.body)
  end
  
end

class MLS::Photo::Parser < MLS::Parser

end
