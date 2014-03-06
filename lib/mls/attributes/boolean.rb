class MLSGem::Attribute::Boolean < MLSGem::Attribute
	
	def load(value) # from_json
		value
	end
	
	alias :dump :load #only for primatives
	
end
