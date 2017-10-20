class Order < ApplicationRecord
  belongs_to :user
	has_many :lineitems, inverse_of: :order, autosave: true, dependent: :delete_all
	accepts_nested_attributes_for :lineitems, reject_if: :reject_value
	validates :user_id, presence: true
	validates :cuisine, presence: true
	default_scope -> { order(created_at: :desc) }
	validates_associated :lineitems

	def get_customer
		User.find_by(id: self.user_id)
	end

	def get_sorted_lineitems
		self.lineitems.all.sort
	end
	
	def get_downloaded
		self.downloaded
	end
	
	def reset_downloaded
	#	self.downloaded = nil
		self.update_attribute(:downloaded, nil)
	end
	
	def set_downloaded
	#	self.downloaded = DateTime.current()
		self.update_attribute(:downloaded, DateTime.current())
	end
	
	private
		def reject_value(attributed)
			attributed['quantity'].to_i == 0
		end
	
end
