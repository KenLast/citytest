module CuisinesHelper

	def	get_cuisine_id(name)
		all = Cuisine.all
		all.each do |cuisine|
			if (cuisine.name == name)
				return cuisine.id
			end
		end
		return nil
	end
	
	def get_cuisine(name)
		all = Cuisine.all
		all.each do |cuisine|
			if (cuisine.name == name)
				return cuisine
			end
		end
		return nil
	end
end
