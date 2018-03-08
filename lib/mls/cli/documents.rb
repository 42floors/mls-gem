require 'fileutils'
require 'digest'

module MLS::CLI::Documents
  
  def self.partition(value, depth: 5)
    split = value.scan(/.{1,4}/)
    split.shift(depth).join("/") + split.join("")
  end
  
  def self.calculate_digest(file)
    md5_digest = Digest::MD5.new
    sha1_digest = Digest::SHA1.new
    sha256_digest = Digest::SHA256.new

    buf = ""
    file.rewind
    while file.read(16384, buf)
      md5_digest << buf
      sha1_digest << buf
      sha256_digest << buf
    end

    {
      md5: md5_digest.hexdigest,
      sha1: sha1_digest.hexdigest,
      sha256: sha256_digest.hexdigest
    }
  end
  
  def self.backup(dir)
    last_sync_file = File.join(dir, '.last_sync')
    
    query = if File.exist?(last_sync_file)
      from_timestamp = Time.iso8601(File.read(last_sync_file))
      Document.where(Document.arel_table['created_at'].gteq(from_timestamp))
    else
      Document.all
    end
    
    query.find_each do |document|
      if document.sha256 && File.exists?(File.join(dir, partition(document.sha256)))
        puts "Downloaded #{document.id}"
        next
      end
      
      if document.provider.nil? || document.provider.include?('s3/hash_key')
        storage_engine = MLS::CLI::Storage::S3.new(MLS::CLI.options[:s3])
        key = 'hash_key'
      else
        raise 'unkown storage engine'
      end
      
      print "Downloading #{document.id.to_s.ljust(7)} "
      storage_engine.copy_to_tempfile(document.send(key)) do |file|
        digests = calculate_digest(file)
        puts partition(document.sha256)
        
        raise 'MD5 does not match' if digests[:md5] != document.md5
        document.update!(digests.merge({provider: ['s3/hash_key']}))
        
        FileUtils.mkdir_p(File.dirname(File.join(dir, partition(document.sha256))))
        FileUtils.mv(file.path, File.join(dir, partition(document.sha256)))
      end
      
      File.write(last_sync_file, document.created_at.iso8601(6))
    end
  end

end


