class MLS::Photo < MLS::Resource

  attr_accessor :digest

  def initialize(digest)
    @digest = digest
  end

  def url(style='large', protocol='http')
    "#{protocol}://#{MLS.asset_host}/photos/#{style}/#{@digest}.jpg"
  end

end
