require 'restclient'

class MLS::Floorplan < MLS::Resource

  property :id, Fixnum
  property :digest, String
  property :avatar_digest, String
  property :file_name, String
  property :file_size, Fixnum
  
  def url(protocol='http')
    "#{protocol}://#{MLS.asset_host}/floorplans/#{digest}/#{file_name}"
  end
  
  def avatar(size='150x100#', protocol='http')
    "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
  
  def self.create(attrs)
    attrs[:file].rewind
    url = MLS.url.dup
    url.user = nil
    url.path = "/api/floorplans"
    
    if attrs[:subject]
      attrs[:subject_id] = attrs[:subject].id
      attrs[:subject_type] = attrs[:subject].class.name.split("::").last
      attrs.delete(:subject)
    end
    response = RestClient.post(url.to_s, {:floorplan => attrs}, MLS.headers)
    attrs[:file].close unless attrs[:file].closed?

    MLS::Floorplan::Parser.parse(response.body)
  end
  
  def self.find(id)
    response = MLS.get("/floorplans/#{id}")
    MLS::Floorplan::Parser.parse(response.body)
  end
  
end

class MLS::Floorplan::Parser < MLS::Parser

end
