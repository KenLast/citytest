class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	include SessionsHelper
	
  private

		# before filters
    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
		
		# Confirms an admin user
		def admin_user
			flash_text = "Administrative privilege required to perform this action."
			flash[:danger] = flash_text unless current_user.admin?
			redirect_to(root_url) unless current_user.admin?
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
		
		def is_inventory(order)
			if User.find_by(id: order.user_id).customerid == "ADMIN"
				if order.name == "Template for #{order.cuisine}"
					return true
				end
			end
			return false
		end
		
		# Pass in Time string and get all orders corresponding to that time
		def order_time(time)
			case(time)
				when "all"
					orders = Order.all
				when "today"
					orders = Order.where(created_at: (Time.current.midnight..Time.current))
				when "yesterday"
					orders = Order.where(created_at: (Time.current.midnight - 1.day)..Time.current.midnight)
				when "since yesterday"
					orders = Order.where(created_at: (Time.current.midnight - 1.day)..Time.current)
				when "this week"
					orders = Order.where(created_at: (Time.current.midnight - 6.day)..Time.current)
				when "older than one year"
					orders = Order.where(created_at: (Time.current - 100.year)..Time.current - 1.year)
				when "older than two years"
					orders = Order.where(created_at: (Time.current - 100.year)..Time.current - 2.year)
				when "older than three years"
					orders = Order.where(created_at: (Time.current - 100.year)..Time.current - 3.year)
				else
					orders = Order.all
			end
			return orders
		end

	end