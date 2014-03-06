class MLSGem::Attribute
	DEFAULT_OPTIONS = { :serialize => :always	}
	
	attr_reader :model, :name, :instance_variable_name, :options, :default
	attr_reader :reader_visibility, :writer_visibility

	def initialize(name, options={})
		@name                   = name
		@instance_variable_name = "@#{@name}".freeze
		@options                = DEFAULT_OPTIONS.merge(options)

		set_default_value
		determine_visibility
	end

	def set_default_value
		@default = @options[:default]
	end

	def determine_visibility # default :public
		@reader_visibility = @options[:reader] || :public
		@writer_visibility = @options[:writer] || :public
	end

	def self.determine_class(type)
		return type if type < MLSGem::Attribute
		find_class(::ActiveSupport::Inflector.demodulize(type))
	end

	def self.inherited(descendant)
		demodulized_names[::ActiveSupport::Inflector.demodulize(descendant.name)] ||= descendant
	end

	def self.demodulized_names
		@demodulized_names ||= {}
	end

	def self.find_class(name)
		klass   = demodulized_names[name]
		klass ||= const_get(name) if const_defined?(name)
		klass
	end
	
end
