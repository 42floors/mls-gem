require 'restclient'

class MLSGem::Floorplan < MLSGem::Resource

  attribute :id, Fixnum
  attribute :digest, String
  attribute :avatar_digest, String
  attribute :file_name, String
  attribute :file_size, Fixnum
  
  def url(protocol='http')
    "#{protocol}://#{MLSGem.asset_host}/floorplans/#{digest}/compressed/#{file_name}"
  end
  
  def avatar(size='150x100#', protocol='http')
    "#{protocol}://#{MLSGem.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
  
  def self.create(attrs)
    attrs[:file].rewind
    url = MLSGem.url.dup
    url.user = nil
    url.path = "/api/floorplans"
    
    if attrs[:subject]
      attrs[:subject_id] = attrs[:subject].id
      attrs[:subject_type] = attrs[:subject].class.name.split("::").last
      attrs.delete(:subject)
    end
    response = RestClient.post(url.to_s, {:floorplan => attrs}, MLSGem.headers)
    attrs[:file].close unless attrs[:file].closed?

    MLSGem::Floorplan::Parser.parse(response.body)
  end
  
  def self.find(id)
    response = MLSGem.get("/floorplans/#{id}")
    MLSGem::Floorplan::Parser.parse(response.body)
  end
  
end

class MLSGem::Floorplan::Parser < MLSGem::Parser

end
