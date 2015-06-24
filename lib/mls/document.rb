class Document < MLS::Model
  
  def self.create(file)
    if doc = find_matching(file)
      doc
    else
      data, headers = Multipart::Post.prepare_query("document[file]" => file)
    
      req = Net::HTTP::Post.new("/documents")
      req.body = data
      req['Content-Type'] = headers['Content-Type']
    
      res = Document.connection.instance_variable_get(:@connection).send_request(req)
      instantiate(JSON.parse(res.body).select{|k,v| column_names.include?(k.to_s) })
    end
  end
  
  def url(style=:original)
    MLS.config['document_host'] + path(style)
  end
  
  def path(style=:original)
    "/documents/#{hash_key}/#{style}#{File.extname(filename)}"
  end

  
  def width
    return nil if !dimensions
    return dimensions.split('x')[0].to_i
  end
  
  def height
    return nil if !dimensions
    return dimensions.split('x')[1].to_i
  end
  
  def aspect_ratio
    return nil if !width || !height
    return width.to_f / height.to_f
  end
  
  def self.find_matching(file)
    filename = file.original_filename if file.respond_to?(:original_filename)
    filename ||= File.basename(file.path)

    # If we can tell the possible mime-type from the filename, use the
    # first in the list; otherwise, use "application/octet-stream"
    content_type = file.content_type if file.respond_to?(:content_type)
    content_type ||= (MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]).simplified

    matching_docs = Document.where(:filename => filename, :content_type => content_type, :size => file.size)
    if matching_docs.count > 0
      matching_docs = matching_docs.where(:md5 => Digest::MD5.file(file.path).hexdigest)
    end
    
    matching_docs.first
  end

end

class Image < Document

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

    result += "#{options[:host]}/#{hash_key}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end

class PDF < Document
  include MLS::Avatar
end



# Takes a hash of string and file parameters and returns a string of text
# formatted to be sent as a multipart form post.
module Multipart
  # Formats a given hash as a multipart form post
  # If a hash value responds to :string or :read messages, then it is
  # interpreted as a file and processed accordingly; otherwise, it is assumed
  # to be a string
  class Post

    def self.prepare_query(params)
      boundary = "-----RubyMultipartClient~#{SecureRandom.hex(32)}"

      parts = params.map do |k, v|
        if v.respond_to?(:path) && v.respond_to?(:read)
          FileParam.new(k, v)
        else
          StringParam.new(k, v)
        end
      end

      query = parts.map {|p| "--#{boundary}\r\n#{p.to_multipart}" }.join('') + "--#{boundary}--"
      return query, { "Content-Type" => "multipart/form-data; boundary=#{boundary}" }
    end
  end

  private

  # Formats a basic string key/value pair for inclusion with a multipart post
  class StringParam
    attr_accessor :k, :v

    def initialize(k, v)
      @k = k
      @v = v
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{@k}\"\r\n\r\n#{v}\r\n"
    end
  end

  # Formats the contents of a file or string for inclusion with a multipart
  # form post
  class FileParam

    def initialize(k, file)
      @k = k
      @file = file

      @filename = file.original_filename if file.respond_to?(:original_filename)
      @filename ||= File.basename(file.path)

      # If we can tell the possible mime-type from the filename, use the
      # first in the list; otherwise, use "application/octet-stream"
      @content_type = file.content_type if file.respond_to?(:content_type)
      @content_type ||= (MIME::Types.type_for(@filename)[0] || MIME::Types["application/octet-stream"][0]).simplified
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{@k}\"; filename=\"#{ @filename }\"\r\n" +
             "Content-Type: #{ @content_type }\r\n\r\n#{ @file.read }\r\n"
    end
  end
end