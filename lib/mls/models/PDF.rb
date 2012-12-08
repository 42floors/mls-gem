class MLS::PDF < MLS::Resource

  property :id, Fixnum
  property :digest, String
  property :file_url, String
  property :type, String

  def url(style='large', protocol='http')
    "#{protocol}://#{MLS.asset_host}/#{type}s/#{style}/#{@digest}.jpg"
  end
end

class MLS::PDF::Parser < MLS::Parser

end
