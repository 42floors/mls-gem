module MLS::Model

  def self.extended(model)
    model.instance_variable_set(:@properties, {})
    model.instance_variable_set(:@associations, {})
  end

  # Properties ===================================================================================================
  
  def property(name, type, options = {})
    klass = MLS::Property.determine_class(type)
    raise NotImplementedError, "#{type} is not supported" unless klass

    property = klass.new(name, options)
    @properties[property.name] = property
    @properties_excluded_from_comparison = []

    create_reader_for(property)
    create_writer_for(property)
  end

  def exclude_from_comparison(*properties)
    @properties_excluded_from_comparison |= properties
  end

  def properties_excluded_from_comparison
    @properties_excluded_from_comparison
  end

  def properties
    @properties
  end

  def property_module
    @property_module ||= begin
      mod = Module.new
      class_eval do
        include mod
      end
      mod
    end
  end

  def create_reader_for(property)
    reader_name             = property.name.to_s
    boolean_reader_name     = "#{reader_name}?"
    reader_visibility       = property.reader_visibility
    instance_variable_name  = property.instance_variable_name

    property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
      #{reader_visibility}
      def #{reader_name}
        return #{instance_variable_name} if defined?(#{instance_variable_name})
        property = properties[:#{reader_name}]
        #{instance_variable_name} = property ? property.default : nil
      end
    RUBY

    if property.kind_of?(MLS::Property::Boolean)
      property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        #{reader_visibility}
        def #{boolean_reader_name}
          #{reader_name}
        end
      RUBY
    end
  end

  def create_writer_for(property)
    name                    = property.name
    writer_name             = "#{name}="
    writer_visibility       = property.writer_visibility
    instance_variable_name  = property.instance_variable_name

    property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
      #{writer_visibility}
      def #{writer_name}(value)
        property = self.class.properties[:#{name}]
        #{instance_variable_name} = property.load(value)
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
