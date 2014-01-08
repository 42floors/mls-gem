class MLS::Attribute::Fixnum < ::MLS::Attribute
	
	def load(value) # from_json
		if value.nil?
			nil
		elsif value.is_a?(::Fixnum)
			value
		else
			value.to_i
		end
		
	end
	
	alias :dump :load #only for primatives
	
end
