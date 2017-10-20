class AdminController < ApplicationController
	before_action	:logged_in_user
	before_action :admin_user

	# view the admin page
	def view
	end
	
	# create the pick order and provide as download stream to file ... from form
	def retrieve
		fname = "pick.txt"
		send_data("from retrieve", type: "txt", filename: fname)
		return
	end
	
	def download_reset
		@orders = order_time(params[:time])
		
		if @orders.count == 0
			flash[:warning] = "No orders #{params[:time]}"
			redirect_to admin_path and return
		end
		
		xcount = 0
		@orders.each do |o|
			if (!is_inventory(o) && !o.get_downloaded.blank?())
				o.reset_downloaded
				xcount = xcount + 1
			end
		end
		
		flash[:success] = "#{xcount} orders reset to non-downloaded status"
		redirect_to admin_path and return

	end

	# create the pick order and provide as download stream to file ... from link
	def download
		# if passed a time period
		if !params[:time].blank?()
			@orders = order_time(params[:time])
			usetext = "#{params[:time]}"
		end
		# if passed a single user id
		if !params[:user].blank?()
			user = User.find_by(id: params[:user])
			@orders = user.orders
			usetext = "User " + user.name
		end
		# if passed a single order number
		if !params[:order].blank?()
			@orders = Array.new
			@orders[0] = Order.find_by(id: params[:order])
			usetext = "Order #{params[:order]}"
		end
		
		if @orders.count == 0
			flash[:warning] = "No orders found in group " + usetext.capitalize
			redirect_to admin_path and return
		end
		
		xcount = 0
		@orders.each do |o|
			if (!is_inventory(o) && o.get_downloaded.blank?())
				xcount = xcount + 1
			end
		end
		
		if xcount == 0
			flash[:warning] = "No unprocessed orders in group " + usetext.capitalize
			redirect_to admin_path and return
		end
		
		
		this_pick = format_orders_for_pick(@orders)
		# is it possible to refresh the current page here???
		t = Time.current.to_time
		fname = "pick " + "#{t.strftime('%c')}" + ".txt"
		# debugger
		send_data(this_pick, type: "txt", filename: fname)
		return           # never gets here
	end

	private
		def format_orders_for_pick(orders)
			line_format = "%10s; %8s; %10s; %9s;  %-35s; %9s; %6s; %5s; %-10s; %-50s\r\n"
			# line_format = "%-24s %9s  %-20s %9s %6s %5s %-10s %-50s\r\n"
			
			all_orders = sprintf(line_format, "Date", "Time", "Special", "CustID", "CustName", "Order", "ProdID", "Qty", "UM", "Description")
			
			orders.each do |order|
				if is_inventory(order) then next end
				customer = User.find_by(id: order.user_id)
				if customer.nil? then next end
				if !order.get_downloaded.blank?() then next end
				order.set_downloaded
				seenote = order.note.blank?() ? " " : "See note"
				# debugger
				order.lineitems.sort.each do |lineitem|
					product = Product.find_by(id: lineitem.product_id)
					if product.nil? then next end
					t = order.created_at

=begin
					this next section is to fix a problem with the code that reads in this file
					convert all quantity units to single units by multiplying out because other code can only read in single unit quantities
					customer sees orders by quantity units if desired, they don't see the conversion
=end
					templi = lineitem
					if product.qum.downcase.strip == lineitem.selum.downcase.strip
						templi.quantity = product.qpu * lineitem.quantity
						templi.selum = product.um
					end
					
					
					oneline = sprintf("%02d/%02d/%4d;  %2d:%2d:%2d", t.day, t.mon, t.year, t.hour, t.min, t.sec)
					justd = sprintf("%02d/%02d/%04d", t.mon, t.day, t.year)
					justt = sprintf("%02d:%02d:%02d", t.hour, t.min, t.sec)
#					all_orders << sprintf(line_format, justd, justt, seenote, customer.customerid, customer.name.slice(0..19), order.id.to_s, product.productid, lineitem.quantity, lineitem.plural, product.name.strip) 
					all_orders << sprintf(line_format, justd, justt, seenote, customer.customerid, customer.name.slice(0..19), order.id.to_s, product.productid, templi.quantity, templi.plural, product.name.strip) 
				end
			end
			return all_orders
		end
		
		private
		def reset_params
		  params.permit(:orders)
		end

end
