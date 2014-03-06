class MLSGem::PDF < MLSGem::Resource

  attribute :id, Fixnum
  attribute :digest, String
  attribute :file_url, String
  attribute :type, String

  def url(style='700x467#', protocol='http')
    "#{protocol}://#{MLSGem.image_host}/#{avatar_digest}.jpg?s=#{URI.escape(size)}"
  end
end

class MLSGem::PDF::Parser < MLSGem::Parser

end
