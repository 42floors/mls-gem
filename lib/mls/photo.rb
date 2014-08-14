module MLS
  class Photo < Sunstone::Model

    def url(style=nil, protocol='http')
      result = "#{protocol}://#{MLS.image_host}/#{digest}.jpg"
      if style
        result = result + "?s=#{URI.escape(style)}"
      end

      result
    end

  end
end
