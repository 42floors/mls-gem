class MLS::Attribute::Boolean < MLS::Attribute
	
	def load(value) # from_json
		value
	end
	
	alias :dump :load #only for primatives
	
end
