class Lineitem < ApplicationRecord
	belongs_to :order, inverse_of: :lineitems
	validates :quantity, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
	
	# define sorting lineitems
	# sorts by associated product's productid
	def <=>(other)
		Product.find_by(id: self.product_id).productid <=> Product.find_by(id: other.product_id).productid
	end
	
	# return the company-specific productid code for the product pointed to by this lineitem
	def get_productid
		return Product.find_by(id: self.product_id).productid
	end
	
	# return the product pointed to by this lineitem
	def get_product
		return Product.find_by(id: self.product_id)
	end
	
	# returns the name of the product pointed to by this lineitem
	def get_name
		return Product.find_by(id: self.product_id).name
	end
	
		# returns the plural form of the selected unit of measure.  Note "each" and "dozen" are treated as special cases
	def plural
		if self.selum == "each"
			return "each"
		end
		if self.selum == "dozen"
			return "dozen"
		end
		return self.selum.pluralize(self.quantity)
	end

end
