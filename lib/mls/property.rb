class Property < MLS::Model

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

end