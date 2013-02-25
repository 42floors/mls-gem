class MLS::PDF < MLS::Resource

  property :id, Fixnum
  property :digest, String
  property :file_url, String
  property :type, String

  def url(style='700x467#', protocol='http')
    "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
end

class MLS::PDF::Parser < MLS::Parser

end
