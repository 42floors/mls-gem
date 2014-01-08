module MLS::Model

  def self.extended(model) #:nodoc:
    model.instance_variable_set(:@attributes, {})
    model.instance_variable_set(:@associations, {})
  end

  # Creates an object and saves it to the MLS. The resulting object is returned
  # whether or no the object was saved successfully to the MLS or not.
  #
  # ==== Examples
  #  #!ruby
  #  # Create a single new object
  #  User.create(:first_name => 'Jamie')
  #  
  #  # Create a single object and pass it into a block to set other attributes.
  #  User.create(:first_name => 'Jamie') do |u|
  #    u.is_admin = false
  #  end
  def create(attributes={}, &block) # TODO: testme
    model = self.new(attributes)
    yield(model) if block_given?
    model.save
    model
  end

  # Attributes ===================================================================================================

  def attribute(name, type, options = {})
    klass = MLS::Attribute.determine_class(type)
    raise NotImplementedError, "#{type} is not supported" unless klass

    attribute = klass.new(name, options)
    @attributes[attribute.name] = attribute
    @attributes_excluded_from_comparison = []

    create_reader_for(attribute)
    create_writer_for(attribute)
  end

  def exclude_from_comparison(*attributes)
    @attributes_excluded_from_comparison |= attributes
  end

  def attributes_excluded_from_comparison
    @attributes_excluded_from_comparison
  end

  def attributes
    @attributes
  end

  def attribute_module
    @attribute_module ||= begin
      mod = Module.new
      class_eval do
        include mod
      end
      mod
    end
  end

  def create_reader_for(attribute)
    reader_name             = attribute.name.to_s
    boolean_reader_name     = "#{reader_name}?"
    reader_visibility       = attribute.reader_visibility
    instance_variable_name  = attribute.instance_variable_name

    attribute_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
      #{reader_visibility}
      def #{reader_name}
        return #{instance_variable_name} if defined?(#{instance_variable_name})
        attribute = attributes[:#{reader_name}]
        #{instance_variable_name} = attribute ? attribute.default : nil
      end
    RUBY

    if attribute.kind_of?(MLS::Attribute::Boolean)
      attribute_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        #{reader_visibility}
        def #{boolean_reader_name}
          #{reader_name}
        end
      RUBY
    end
  end

  def create_writer_for(attribute)
    name                    = attribute.name
    writer_name             = "#{name}="
    writer_visibility       = attribute.writer_visibility
    instance_variable_name  = attribute.instance_variable_name

    attribute_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
      #{writer_visibility}
      def #{writer_name}(value)
        attribute = self.class.attributes[:#{name}]
        #{instance_variable_name} = attribute.load(value)
      end
    RUBY
  end

  #== for rails form stuff
  def model_name
    self
  end
  
  def param_key
    root_element.to_s
  end
  
  # used for parser
  def root_element_string
    ActiveSupport::Inflector.demodulize(self).underscore
  end

  def root_element
    @root_element ||= root_element_string.to_sym
  end
  
  def collection_root_element
    @collection_root_element ||= root_element_string.pluralize.to_sym
  end
  
end
