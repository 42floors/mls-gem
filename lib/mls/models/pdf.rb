class MLS::PDF < MLS::Resource

  attribute :id, Fixnum
  attribute :digest, String
  attribute :file_url, String
  attribute :type, String

  def url(style='700x467#', protocol='http')
    "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
end

class MLS::PDF::Parser < MLS::Parser

end
