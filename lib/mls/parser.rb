class MLS::Parser
  
  attr_reader :object
  
  def initialize(object=nil, persisted=true)
    @object = object || self.class.object_class.new({}, persisted)
  end
  
  def parse(data)
    attributes = extract_attributes(data)[self.class.root_element]
    update_attributes(attributes)
    object
  end
  
  def build(attributes)
    update_attributes(attributes)
    object
  end
  
  def update_attributes(attributes)
    attributes.each {|k,v| self.send("#{k}=".to_sym, v) } if attributes
  end
  
  def self.parse(data)
    self.new.parse(data)
  end

  # TODO: TEST ME
  def self.build_collection(hash, options={})
    root = options[:collection_root_element] || collection_root_element
    collection = []
    hash[root].each do |attrs|
      collection << build(attrs)
    end
    collection
  end
  
  def self.parse_collection(data, options={})
    build_collection(extract_attributes(data), options)
  end
  
  def self.build(attributes)
    self.new.build(attributes)
  end
  
  def self.update(object, data)
    self.new(object).parse(data)    
  end
  
  def method_missing(method, *args, &block)
    object.__send__(method, *args, &block) if object.methods.include?(method)
  end  
  
  def extract_attributes(data)
    Yajl::Parser.new(:symbolize_keys => true).parse(data)
  end
  def self.extract_attributes(data)
    Yajl::Parser.new(:symbolize_keys => true).parse(data)
  end

  def self.object_class
    @object_class ||= ActiveSupport::Inflector.constantize(self.to_s.sub('::Parser',''))
  end
  
  def self.root_element
    object_class.root_element
  end
  
  def self.collection_root_element
    object_class.collection_root_element
  end
  
end
