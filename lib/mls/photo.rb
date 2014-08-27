class Photo < MLS::Model

  belongs_to :subject, :polymorphic => true
  
  def url(style=nil, protocol='http')
    result = "#{protocol}://#{MLS.image_host}/#{digest}.jpg"
    if style
      result = result + "?s=#{URI.escape(style)}"
    end

    result
  end
    
end