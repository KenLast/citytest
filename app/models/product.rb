class Product < ApplicationRecord
	default_scope -> { order :productid }

	# check if product is current
	def current?
		self.discontinued == false
	end
	
	# check if product has been discontinued
	def discontinued?
		self.discontinued == true
	end
	
	# set product as current
	def set_current
		self.discontinued = false
	end
	
	# set product as discontinued
	def set_discontinued
		self.discontinued = true
	end

end
