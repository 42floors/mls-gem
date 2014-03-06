class MLSGem::Attribute::String < MLSGem::Attribute
	
	def load(value) # from_json
		if value.nil?
			nil
		elsif value.is_a?(::String)
			value
		else
			value.to_s
		end
	end
	
	alias :dump :load #only for primatives
	
end
