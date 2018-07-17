require 'b2'

module MLS::CLI::Storage
  class B2
    
    def initialize(configs = {})
      @configs = configs
      @configs[:prefix] ||= ""
      
      @client = B2::Bucket.new({
        'bucketId' => configs[:bucket_id]
      }, B2.new({
        account_id: configs[:account_id],
        application_key: configs[:application_key]
      }))
    end
    
    def local?
      false
    end
      
    # def url(key)
    #   [host, destination(key)].join('/')
    # end
    
    # def host
    #   h = @configs[:bucket_host_alias] || "https://s3.amazonaws.com/#{@configs[:bucket]}"
    #   h.delete_suffix('/')
    # end
    
    def destination(key)
      "#{@configs[:prefix]}#{partition(key)}".gsub(/^\//, '')
    end
    
    def exists?(key)
      @client.has_key?(destination(key))
    end
    
    def write(key, file, meta_info)
      file = file.tempfile if file.is_a?(ActionDispatch::Http::UploadedFile)
      file = File.open(file) if file.is_a?(String)
      
      @client.upload_file(key, file, mime_type: meta_info[:content_type], sha1: meta_info[:sha1], content_disposition: "inline; filename=\"#{meta_info[:filename]}\"")
    end
    
    def download(key, to=nil, &block)
      @client.download(destination(key), to, &block)
    end
    
    def delete(key)
      @client.delete!(key)
    end
    
    def copy_to_tempfile(key)
      tmpfile = Tempfile.new([File.basename(key), File.extname(key)], binmode: true)
      download(key, tmpfile.path)
      if block_given?
        begin
          yield(tmpfile)
        ensure
          tmpfile.close!
        end
      else
        tmpfile
      end
    end
    
    def partition(value)
      return value unless @configs[:partition]
      split = value.scan(/.{1,4}/)
      split.shift(@configs[:partition_depth] || 3).join("/") + split.join("")
    end
    
    def sha1(key)
      @client.file(destination(key)).sha1
    end
  
    def last_modified(key)
      @client.file(destination(key)).uploaded_at
    end
    
    def mime_type(key)
      @client.file(destination(key)).mime_type
    end
    
  end
end