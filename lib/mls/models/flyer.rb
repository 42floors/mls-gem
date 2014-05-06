require 'restclient'

class MLSGem::Flyer < MLSGem::Resource

  attribute :id, Fixnum
  attribute :digest, String
  attribute :avatar_digest, String
  attribute :file_name, String
  attribute :file_size, Fixnum
  
  def url(protocol='http')
    "#{protocol}://#{MLSGem.asset_host}/flyers/#{digest}/compressed/#{file_name}"
  end
  
  def avatar(size='150x100#', protocol='http')
    "#{protocol}://#{MLSGem.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
  
  def self.create(attrs)
    attrs[:file].rewind
    url = MLSGem.url.dup
    url.user = nil
    url.path = "/flyers"
    
    if attrs[:subject]
      attrs[:subject_id] = attrs[:subject].id
      attrs[:subject_type] = attrs[:subject].class.name.split("::").last
      attrs.delete(:subject)
    end
    response = RestClient.post(url.to_s, {:flyer => attrs}, MLSGem.headers)
    attrs[:file].close unless attrs[:file].closed?

    MLSGem::Flyer::Parser.parse(response.body)
  end
  
  def self.find(id)
    response = MLSGem.get("/flyers/#{id}")
    MLSGem::Flyer::Parser.parse(response.body)
  end
  
end

class MLSGem::Flyer::Parser < MLSGem::Parser

end
