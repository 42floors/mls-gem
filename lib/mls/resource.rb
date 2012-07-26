class MLS::Resource

  attr_reader :persisted
  attr_accessor :errors

  def self.inherited(subclass)
    subclass.extend(MLS::Model)
  end

  def initialize(attributes = {}, persisted = false)
    @persisted = persisted
    @errors = {}
    
    set_default_values
    update_attributes(attributes)
  end
  
  def new_record?
    !@persisted
  end
  
  def persisted?
    @persisted
  end
  
  def save
    new_record? ? create : update
  end

  def save!
    new_record? ? create! : update!
  end
  
  # Properties ===================================================================================================
  
  def properties
    self.class.properties
  end
  
  def set_default_values
    properties.each do |name, property|
      self.send("#{name}=".to_sym, property.default) if property.default
    end
  end

  def update_attributes(attrs)
    attrs.each { |k, v| self.send("#{k}=".to_sym, v) } unless attrs.nil?
  end
  
  # Combo Breaker ================================================================================================

  def to_hash
    hash = {}
    
    properties.each do |name, property|
      serialize = property.options[:serialize] || :always
      case serialize
      when :always
        hash[name] = property.dump(self.send(name))
      when :if_present
        hash[name] = property.dump(self.send(name)) if self.send(name)
      end
    end
    
    hash
  end
  
  #== for rails form stuff
  
  def to_key
    persisted? ? [id] : nil
  end
  
end
