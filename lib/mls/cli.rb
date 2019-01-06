require File.expand_path('../../mls', __FILE__)
require 'uri'
require 'optparse'

module MLS::CLI

  def self.options
    if !class_variable_defined?(:@@options)
      @@options = {}
    end
    @@options
  end
  
  def self.parse_args(args)
    OptionParser.new do |opts|
      opts.on("-aURL", "--auth=URL", "URL Credentials for MLS, S3 or B2") do |arg|
        url = URI.parse(arg)
        case url.scheme
        when 's3' # ACCESS_KEY:SECRET_KEY@BUCKET[/PREFIX][?parition=4]
          MLS::CLI.options[:s3] = {
            access_key_id:      URI.unescape(url.user),
            secret_access_key:  URI.unescape(url.password),
            bucket:             URI.unescape(url.host)
          }
          MLS::CLI.options[:s3][:prefix] = url.path if url.path && !url.path.empty?
          url.query.split('&').each do |qp|
            key, value = qp.split('=').map { |d| URI.unescape(d) }
            case key
            when 'partition'
              MLS::CLI.options[:s3][:partition] = true
              MLS::CLI.options[:s3][:partition_depth] = value.to_i
            end
          end
        when 'b2'
          MLS::CLI.options[:b2] = {
            account_id:         URI.unescape(url.user),
            application_key:    URI.unescape(url.password),
            bucket:             URI.unescape(url.host),
            prefix:             url.path&.empty? ? url.path : nil
          }
          url.query.split('&').each do |qp|
            key, value = qp.split('=').map { |d| URI.unescape(d) }
            case key
            when 'partition'
              MLS::CLI.options[:b2][:partition] = value.to_i
            end
          end
        when 'mls'
          arg = arg.sub('mls://', 'https://')
          MLS::CLI.options[:mls] = arg
          MLS::Model.establish_connection(adapter: 'sunstone', url: arg)
        end
      end
    end.parse!(args)
  end
  
end

require 'standard_storage'
require File.expand_path('../cli/documents', __FILE__)
