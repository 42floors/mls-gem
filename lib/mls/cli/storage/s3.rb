require 'aws-sdk-s3'

module MLS::CLI::Storage
  class S3
    
    def initialize(configs = {})
      @configs = configs
      @configs[:region] ||= 'us-east-1'
      @configs[:prefix] ||= ""
      
      @client = Aws::S3::Client.new({
        access_key_id: configs[:access_key_id],
        secret_access_key: configs[:secret_access_key],
        region: configs[:region]
      })
    end
    
    def object_for(key)
      Aws::S3::Object.new(@configs[:bucket], key, client: @client)
    end
      
    def local?
      false
    end
      
    def url(key)
      [host, destination(key)].join('/')
    end
      
    def host
      h = @configs[:bucket_host_alias] || "https://s3.amazonaws.com/#{@configs[:bucket]}"
      h.delete_suffix('/')
    end
    
    def destination(key)
      "#{@configs[:prefix]}#{partition(key)}".gsub(/^\//, '')#delete_prefix('/')
    end
    
    def exists?(key)
      object_for(destination(key)).exists?
    end
    
    # def write(key, file, meta_info)
    #   file = file.tempfile if file.is_a?(ActionDispatch::Http::UploadedFile)
    #
    #   object_for(destination(key)).upload_file(file, {
    #     :acl => 'public-read',
    #     :content_disposition => "inline; filename=\"#{meta_info[:filename]}\"",
    #     :content_type => meta_info[:content_type]
    #   })
    # end
    
    def read(key, &block)
      object_for(destination(key)).get()
    end
    
    def cp(key, path)
      object_for(destination(key)).get({ response_target: path })
      true
    end
    
    def delete(key)
      object_for(destination(key)).delete
    end
    
    def copy_to_tempfile(key)
      tmpfile = Tempfile.new([File.basename(key), File.extname(key)], binmode: true)
      cp(key, tmpfile.path)
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
    
    def md5(key)
      object_for(destination(key)).etag
    end
  
    def last_modified(key)
      object_for(destination(key)).last_modified
    end
    
    def mime_type(key)
      object_for(destination(key)).content_type
    end
    
  end
end