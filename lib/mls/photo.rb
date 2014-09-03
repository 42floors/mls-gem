class Photo < MLS::Model

  belongs_to :subject, :polymorphic => true, :inverse_of => :photos
    
  def url(options={})
    options.reverse_merge!({
      :style => nil,
      :protocol => "http",
      :bg => nil,
      :format => "jpg"
    });
    url_params = {s: options[:style], bg: options[:bg]}.select{ |k, v| v }
    result = "#{options[:protocol]}://#{MLS.image_host}/#{digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end
end