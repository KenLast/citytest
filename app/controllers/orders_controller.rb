class OrdersController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy, :edit, :index, :cancel]
	before_action :admin_user, only: [:index]
	before_action :order_owner, only: [:show, :edit, :update, :destroy]


	def index
		@orders = order_time(params[:time])
		@user = current_user
		if @orders.count == 0
			flash[:warning] = "No orders #{params[:time]}"
			redirect_back(fallback_location: admin_path) and return
		end
		if params[:time].nil?
			@time = "All "
		else
			if params[:time] == "all"
				@time = "All "
			else
				@time = params[:time].capitalize + "'s "
			end
		end
	end

	def show
		@order = Order.find_by(id: params[:id])   # old order
		@user = User.find_by(id: @order.user_id)
		@orderdate = @order.created_at
	end
	
	# start a new order
	def new
		@user = User.find_by(id: params[:owner])
		@order = Order.new
		@order.cuisine = @user.cuisine
		@cuisine_inventory = get_inventory(@user.cuisine)
		if @cuisine_inventory.nil?
			flash[:danger] = "Order failed. Cuisine template unavailable. Contact City Produce."
			redirect_to contact_path and return    # was render 'new'		
		end
#		debugger
		if !@cuisine_inventory.lineitems.empty?
			@cuisine_inventory.lineitems.sort.each do |l|
				@order.lineitems.build(product_id: l.product_id,
																quantity: 0,
																selum: l.selum)
			end
		end
#		@full_inventory = get_inventory("Inventory")
#		debugger
	end

	# result of form from new
	# POST order
	def create
		isuser = params[:order][:user_id]
		if isuser.nil?
			@user = current_user
		else
			@user = User.find_by(id: isuser.to_i)
		end
		@order = @user.orders.build(order_params)
		
		if @order.name.blank?
			@order.name = 'unnamed'
		end
		
		if @order.save
			flash[:success] = "Order created!"
			redirect_to @user and return
		else
#			debugger
			flash[:danger] = "Order failed, not saved"
			redirect_to new_order_path and return    # was render 'new'
		end
	end
	
	# PATCH order/number is used for both types of reorder
	# @order is the original order. This will not be changed in the database
	# @reorder will be the new one, copied from both @order and the form results
	def update
		@order = Order.find_by(id: params[:id])
		@user = User.find_by(id: @order.user_id)
		if ((current_user == @user) || current_user.admin?)
			if params[:order].nil?
				# called from exact reorder - so no form was used.
				# just copy the original order and be done with it
				oname = reorder_name(@order.name)
				@reorder = @user.orders.build(note: @order.note, name: oname, cuisine: @order.cuisine)
				@order.lineitems.sort.each do |l|
					r = @reorder.lineitems.build(product_id: l.product_id,
																quantity: l.quantity,
																selum: l.selum)
					r.save
				end
			else
				# called from a modified reorder -- from edit path
				@reorder = @user.orders.build(order_params)
#				@reorder.cuisine = @user.cuisine
				# at this point, get the new products from the form
				# as of today (11/10/16) only the name and notes are in params
			end
		else   # should not be here
			flash[:danger] = "Order failed; wrong owner"
			redirect_to new_order_path and return    # was render 'new'
		end
#		debugger

		if @reorder.name.blank?
			@reorder.name = 'unnamed'
		end


		if @reorder.save
			# need to copy products into here
			flash[:success] = "Order created!"
		else
			# debugger
			flash[:danger] = "Order failed, not saved"
		end
		# go back to customer's home page
		redirect_to User.find_by(id: @reorder.user_id) and return
	end
	
# GET order/number/edit is used for editing an order for reorder 
	def edit
		@porder = Order.find_by(id: params[:id])   # old order
		@user = User.find_by(id: @porder.user_id)
		@orderdate = @porder.created_at

		# if this is showing an existing inventory order, just go right to showing the inventory
		if is_inventory(@porder)
			@order = @porder     # /inventory/view expects instance variable @order
			render '/inventory/view' and return
		end
	
		@cuisine_inventory = get_inventory(@porder.cuisine)
		if @cuisine_inventory.nil?
				flash[:danger] = "Order failed: No inventory template. Contact City Produce."
				redirect_to contact_path and return
		end

		@order = @user.orders.build(note: @porder.note, name: @porder.name, cuisine: @porder.cuisine)

#   build new order with all existing products
		@porder.lineitems.sort.each do |l|
			@order.lineitems.build(quantity: l.quantity,
														selum: l.selum,
														product_id: l.product_id)
		end

		if (@porder.cuisine != @order.cuisine)
		# user just switched restaurant types.... so allow products from new cuisine
			@cuisine_inventory = get_inventory(@order.cuisine)
			if @cuisine_inventory.nil?
				flash[:danger] = "No inventory for #{@order.cuisine}"
				redirect_to @user and return
			end
		end
		
#   add all the remaining products from allowable inventory
		if @cuisine_inventory.lineitems.any?
			@cuisine_inventory.lineitems.sort.each do |l|
				found = false
				@porder.lineitems.each do |x|
					if (found == false)
						if (x.product_id == l.product_id)
							found = true
						end
					end
				end
				if (found == false)
					@order.lineitems.build(quantity: 0,
																selum: l.selum,
																product_id: l.product_id)
				end
			end
		end
#		@full_inventory = get_inventory("Inventory")
#		debugger
	end
	
	def download_reset
		useid = params[:format]
		@order = Order.find_by(id: useid)
		@order.reset_downloaded
		flash[:success] = "Download indicator reset"
		redirect_to order_path(useid)
	end
	
	def purge
		@orders = order_time(params[:time])
		if @orders.count == 0
			flash[:warning] = "No orders #{params[:time]}"
			redirect_back(fallback_location: admin_path) and return
		end
		c = 0
		@orders.each do |o|
			if !is_inventory(o)
				o.destroy
				c = c + 1
			end
		end
		
		if (c > 0)
			flash[:success] = "#{c.to_s} orders #{params[:time]} purged"
		else
			flash[:warning] = "No orders #{params[:time]}"
		end
		redirect_back(fallback_location: admin_path) and return
	end
	
	def destroy
	end
	
	# "CANCEL" link from show orders
	def cancel
		useid = params[:format]
		@order = Order.find_by(id: useid)
    if @order.nil?
			flash[:danger] = "Order can not be cancelled - invalid order"
			if current_user.admin?
				redirect_to admin_path and return
			else
				redirect_to current_user and return
			end
		end
		@user = User.find_by(id: @order.user_id)
    if @user.nil?
			flash[:danger] = "Order \"#{@order.name}\" can not be cancelled - invalid user"
			if current_user.admin?
				redirect_to admin_path and return
			else
				redirect_to current_user and return
			end
		end

		if !(current_user?(@user) || current_user.admin?)
			flash[:danger] = "Must be owner to perform this action."
			redirect_to(root_url) and return
		end

		a = @order.destroy
		if !a
			flash[:danger] = "Order \"#{@order.name}\" could not be cancelled"
		else
			flash[:success] = "Order \"#{@order.name}\" has been cancelled"
		end
		
		if current_user.admin?
			redirect_back(fallback_location: admin_path) and return
		else
			redirect_to current_user and return
		end
	end

	
	private
	  def order_params_only
			params.require(:order).permit(:note, :name)
		end
	
		def order_params
			params.require(:order).permit(:note, :name, :cuisine, lineitems_attributes: [:order_id, :id, :product_id, :quantity, :selum])
		end

    # Confirms this is the order owner
    def order_owner
			@order = Order.find_by(id: params[:id])
			if !@order
				flash[:danger] = "That page does not exist"
				redirect_to(root_url) and return
			end
			@user = User.find_by(id: @order.user_id)
			if !@user
				flash[:danger] = "That page does not exist"
				redirect_to(root_url) and return
			end

			if !(current_user?(@user) || current_user.admin?)
				flash[:danger] = "Must be owner to perform this action."
				redirect_to(root_url) and return
			end
		end

		def reorder_name(name)
			if name.start_with?("RE: ")
				return name
			end
			n = "RE: " + name
			return n
		end
		
end
