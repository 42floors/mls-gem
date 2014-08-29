class Flyer < MLS::Model

  belongs_to :subject, :polymorphic => true
  belongs_to :avatar, :class_name => 'Photo'
  
  def avatar_url(options={})
    options.reverse_merge!({
      :style => nil,
      :protocol => "http",
      :bg => nil,
      :format => "jpg"
    });
    url_params = {s: options[:style], bg: options[:bg]}.select{ |k, v| v }
    result = "#{options[:protocol]}://#{MLS.image_host}/#{avatar_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 1

    result
  end
  
  def url
    "http://#{MLS.asset_host}/#{self.class.underscore}/#{digest}/compressed/#{filename}"
  end
    
end