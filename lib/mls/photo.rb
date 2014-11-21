class Photo < MLS::Model

  belongs_to :subject, :polymorphic => true, :inverse_of => :photos
    
  def url(options={})
    options.reverse_merge!({
      :style => nil,
      :bg => nil,
      :protocol => 'https',
      :format => "jpg",
      :host => MLS.image_host
    });

    url_params = {s: options[:style], bg: options[:bg]}.select{ |k, v| v }

    if options[:protocol] == :relative # Protocol Relative
      result = '//'
    else options[:protocol]
      result = "#{options[:protocol]}://"
    end

    result += "#{options[:host]}/#{digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end
end


class InternalPhoto < Photo; end 