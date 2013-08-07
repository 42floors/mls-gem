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
  property :caption, String
  property :subject_id, Fixnum

  def url(style=nil, protocol='http')
    result = "#{protocol}://#{MLS.image_host}/#{digest}.jpg"
    if style
      result = result + "?s=#{URI.escape(style)}"
    end
    
    result
  end

  def self.create(attrs)
    attrs[:file].rewind
    url = MLS.url.dup
    url.user = nil
    url.path = "/api/photos"
    response = RestClient.post(url.to_s, {:file => attrs[:file]}, MLS.headers)
    attrs[:file].close unless attrs[:file].closed?

    MLS::Photo::Parser.parse(response.body)
  end
  
end

class MLS::Photo::Parser < MLS::Parser

end
