class Property < MLS::Model

  include MLS::Slugger
  
  belongs_to :avatar, :class_name => 'Photo'
  
  has_many :listings

  has_many   :addresses
  has_one    :address, -> { where(:primary => true) }
  
  # TODO: move to avatar module to share with other models
  def avatar_url(style=nil, protocol='http')
    result = "#{protocol}://#{MLS.image_host}/#{avatar_digest}.jpg"
    result += "?s=#{URI.escape(style)}" if style

    result
  end
  
  def image_server_url(digest, size, bg=false, format="jpg")
    "http://#{MLS.image_host}/#{digest}.#{format}?s=#{CGI.escape(size)}#{bg ? "&bg=" + CGI.escape(bg) : ""}"
  end
  
  
  
end