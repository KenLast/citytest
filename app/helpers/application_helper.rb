module ApplicationHelper

# Returns the full title on a per-page basis

  def full_title(page_title = '')
	  base_title = "City Produce Ordering"
		if page_title.empty?
		  a = base_title
		else
		  a = page_title
		end
		return (a)
	end
	
	# returns true if there is no difference between single UM and quantity UM
	def no_quantity_type(product)
		return (product.um == product.qum)
	end
	
	def pick_order_path(order)
		u = User.find_by(id: order.user_id)
		if (current_user == u)
			return edit_order_path(order)
		end
		if is_inventory(order)
			return edit_order_path(order)
		end
		return order_path(order)
	end
	
	def calculate_rows(text)
		if text.nil?
			return nil
		else
			return text.lines.count
		end
	end

	def is_inventory(order)
		if User.find_by(id: order.user_id).customerid == "ADMIN"
			if order.name == "Template for #{order.cuisine}"
					return true
			end
		end
		return false
	end

	def get_inventory(name)
		user = User.find_by(customerid: "ADMIN")
		orders = user.orders
		orders.each do |o|
			if o.name == "Template for #{name}"
				return o
			end
		end
		return nil
	end
	
	def get_last_order(user)
		if user.nil?
			return nil
		end
		if user.orders.nil?
			return nil
		end
		order = user.orders.first
		return order
	end
	
	def display_inventory(order)
		if @cuisine_history.nil?
			return false
		end
		if @cuisine_history == "all"
			return true
		end
		if (is_inventory(order) && (order.cuisine == @cuisine_history))
			return true
		end
		return false
	end
	
	def get_user_from_id(p_id)
		if p_id.nil?
			return nil
		else
			return User.find_by(id: p_id)
		end
	end

	# takes the create_at field and produces a combined string
	def big_time_string(time)
		s = time.to_formatted_s(:long) + " - " + time_ago_in_words(time) + " ago"
		return s
	end
	
	def time_ago_string(time)
		s = time_ago_in_words(time) + " ago"
		return s
	end
	
	def small_time_string(time)
		s = time.to_formatted_s(:long)
		return s
	end
	
	# determine where to send user when clicks on "City Produce" logo
	def get_logo_route
		if !logged_in?
			return root_path
		end
		if current_user.admin?
			return admin_path
		end
		return current_user
	end
	
	# determine logo to display based on admin user
	def get_logo_display
		if !logged_in?
			return "City Produce"
		end
		if current_user.admin?
			return "Admin"
		end
		return "Home"
	end
	
	# get the most recent orders from one user or all users
	# if user is nil, then gets all the most recent orders
	# if from is nil or 0, then gets the orders since midnight.
	# any integer is the number of days prior.  0 is today, same as nil
	def recent_orders(user, from)
		if from.nil?
			start = 0
		else
			start = from
		end
			
		if user.nil?
			orders = Order.where(created_at: (Time.current.midnight - start.day)..Time.current)
		else
			orders = user.orders.where(created_at: (Time.current.midnight - start.day)..Time.current)
		end
		return orders
	end
end
