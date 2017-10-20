class Cuisine < ApplicationRecord
	validates :name, presence: true, length: { maximum: 255 },
								uniqueness: { case_sensitive: false }
#	default_scope -> { order(created_at: :desc) }

	def get_customer_count(name)
		count = 0
		users = User.all
		users.each do |u|
			if (u.cuisine == name)
				count = count + 1
			end
		end
		return count
	end
	
end
