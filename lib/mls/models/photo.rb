require 'restclient'

class MLSGem::Photo < MLSGem::Resource

  attribute :id, Fixnum
  attribute :digest, String
  attribute :created_at, DateTime
  attribute :updated_at, DateTime
  attribute :file_content_type, String
  attribute :file_name, String
  attribute :file_size, Fixnum
  attribute :url_template, String
  attribute :caption, String
  attribute :subject_id, Fixnum

  def url(style=nil, protocol='http')
    result = "#{protocol}://#{MLSGem.image_host}/#{digest}.jpg"
    if style
      result = result + "?s=#{URI.escape(style)}"
    end
    
    result
  end

  def self.create(attrs)
    attrs[:file].rewind
    url = MLSGem.url.dup
    url.user = nil
    url.path = "/photos"
    response = RestClient.post(url.to_s, {:photo => attrs}, MLSGem.headers)
    attrs[:file].close unless attrs[:file].closed?

    MLSGem::Photo::Parser.parse(response.body)
  end
  
end

class MLSGem::Photo::Parser < MLSGem::Parser

end
