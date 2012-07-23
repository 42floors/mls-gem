class MLS::Property::Boolean < MLS::Property
	
	def load(value) # from_json
		!!value # !! booleanizes the value
	end
	
	alias :dump :load #only for primatives
	
end
