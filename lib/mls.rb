require 'phony'
require 'sunstone'
require 'arel/extensions'
require 'bcrypt'

module MLS

  API_VERSION = '0.1.0'

  def request_headers
    super
    super.merge({
      'Api-Version' => API_VERSION
    })
  end

  def self.asset_host
    config['asset_host']
  end

  def self.image_host
    config['image_host']
  end

  def self.config
    @config ||= MLS::Model.connection.server_config
  end

  # Set a cookie jar to use during request sent during the
  def self.with_cookie_store(store, &block)
    Thread.current[:sunstone_cookie_store] = store
    yield
  ensure
    Thread.current[:sunstone_cookie_store] = nil
  end

  def self.with_api_key(key, &block)
    Thread.current[:sunstone_api_key] = key
    yield
  ensure
    Thread.current[:sunstone_api_key] = nil
  end

end

class MLS::Model < ActiveRecord::Base
  self.abstract_class = true
end

module MLS::Slugger

  extend ActiveSupport::Concern

  included do
    class_attribute :slugger
    send :include, MLS::Slugger::ActiveRecordBaseSluggerExtension
    relation.class.send :include, MLS::Slugger::ActiveRecordRelationSluggerExtension
  end

  module ActiveRecordBaseSluggerExtension
    extend ActiveSupport::Concern

    # TODO: Test
    def to_param
      slug? ? slug : super
    end

    def set_slug
      generated_slug = if self.slugger[:proc].is_a?(Proc)
        if (self.slugger[:proc].arity == 1)
          self.slugger[:proc].call(self)
        else
          self.slugger[:proc].call
        end
      else
        send(self.slugger[:proc])
      end
      generated_slug = generated_slug ? generated_slug.split('/').map(&:parameterize).join('/') : nil

      if self.slugger[:options][:history]
        self.slugger[:slug_was] = self.slug
      end

      if [:before_validation, :after_validation, :before_save, :before_create].include?(self.slugger[:options][:trigger])
        self.slug = generated_slug
      else
        update_column(:slug, generated_slug) if slug != generated_slug
      end
    end

    module ClassMethods

      def slug(method, options={}, &block)
        options = options.with_indifferent_access
        options[:trigger] ||= :after_save
        self.slugger = { :proc => method || block, :options => options }
        self.send(options[:trigger], :set_slug)
        self.send(:include, Slugger::History) if options[:history]
      end

      def find(*ids)
        friendly = -> (id) { id.respond_to?(:to_i) && id.to_i.to_s != id.to_s }
        return super if ids.size > 1 || !ids.all? { |x| friendly.call(x) }
        
        if ids.first.include?("@")
          self.filter(email_addresses: {address: ids.first}).first
        else
          find_by_slug!(ids.first)
        end
      end

    end

  end

  module ActiveRecordRelationSluggerExtension

    def find_one(id)
      friendly = id.respond_to?(:to_i) && id.to_i.to_s != id.to_s
      friendly ? find_by_slug!(id) : super
    end

    def find_some(ids)
      friendly = -> (id) { id.respond_to?(:to_i) && id.to_i.to_s != id.to_s }
      return super if !ids.all? { |x| friendly.call(x) }

      result = where(table['slug'].in(ids)).to_a

      expected_size =
      if limit_value && ids.size > limit_value
        limit_value
      else
        ids.size
      end

      # 11 ids with limit 3, offset 9 should give 2 results.
      if offset_value && (ids.size - offset_value < expected_size)
        expected_size = ids.size - offset_value
      end

      if result.size == expected_size
        result
      else
        raise_record_not_found_exception!(ids, result.size, expected_size)
      end
    end

  end
end

module MLS::Avatar

  extend ActiveSupport::Concern

  included do
    belongs_to :avatar, :class_name => 'Image'
  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'mls', '*.rb'), &method(:require))
